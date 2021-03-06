# AUTOGENERATED! DO NOT EDIT! File to edit: nbs/00_encryption.ipynb (unless otherwise specified).

__all__ = ['process_dirs', 'encrypt_file', 'pv', 'decrypt_file']

# Cell
import cryptography
from cryptography.fernet import Fernet
from fastcore.all import *
from pathlib import Path
from functools import partial
from shutil import copyfile
import os

# Cell
def process_dirs(p:Path,fn=None,invalid_exts='mca'):
    p=Path(p)
    if p.is_file(): return fn(p,invalid_exts=invalid_exts)
    for dirpath,dirnames,filenames in os.walk(str(p)):
        if len(dirnames)==0 and len(filenames)==0: continue
        for f in filenames: fn(Path(dirpath)/Path(f),invalid_exts=invalid_exts)

# Cell
pv=lambda msg,v:(print(msg) if v else None)

def encrypt_file(p:Path,to_p:Path=None,block_sz=65536,verbose=False,prefix='encrypted',key=None,
                invalid_exts=''):
    p=Path(p)
    to_p=ifnone(to_p,Path(prefix)/p)
    key=ifnone(key,Fernet.generate_key())
    encryptor=Fernet(key)
    os.makedirs(str(Path(to_p).parent),exist_ok=True)

    if p.suffix[1:] in invalid_exts.split(','):
        copyfile(str(p),str(to_p))
        return key

    with open(p,'rb') as f,open(to_p,'wb') as to_f:
        fb=f.read(block_sz)
        while len(fb)>0:
            token=encryptor.encrypt(fb)
            pv(token,verbose)
            to_f.write(token)
            fb=f.read(block_sz)
    return key

# Cell
def decrypt_file(p:Path,key,to_p:Path=None,block_sz=65536,verbose=False,prefix='decrypted',
                invalid_exts=''):
    p=Path(p)
    pv(p,verbose)
    to_p=ifnone(to_p,prefix/p)
    decryptor=Fernet(key)
    os.makedirs(str(Path(to_p).parent),exist_ok=True)
    if p.suffix[1:] in invalid_exts.split(','):
        copyfile(str(p),str(to_p))
        return key

    with open(p,'rb') as f,open(to_p,'wb') as to_f:
        fb=f.read(block_sz)
        while len(fb)>0:
            token=decryptor.decrypt(fb)
            to_f.write(token)
            fb=f.read(block_sz)
    return key
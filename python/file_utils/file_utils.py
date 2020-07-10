#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Feb 15 10:10:53 2019

@author: dkleindienst
"""
import os


def file2dict(filename,delimiter=','):
    with open(filename,'r') as f:
        lines=f.readlines()
    sp=[x.strip('\n').split(delimiter) for x in lines]
    header=sp[0]
    sp=sp[1:]
    dic=dict()
    for i,h in enumerate(header):
        elements=[x[i] for x in sp]
        dic[h]=elements
    return dic

def dict2file(filename,dic,delimiter=',',emptySpace=''):
    '''Writes dictionary dic to file.
    Dictionary keys will serve as fileheader
    delimiter: seperates different keys from each other
    emptySpace: if one of the dictionary field is shorter, this will be written for missing values'''
    
    with open(filename,'w') as f:
        f.write(delimiter.join(dic.keys()))
        lengths=[len(dic[k]) for k in dic]
        for i in range(max(lengths)):
            f.write('\n')
            vals=[dic[k][i] if lengths[ki]>i else emptySpace for ki,k in enumerate(dic.keys())]
            f.write(delimiter.join(vals))



def safe_mkdir(path):
    if not os.path.isdir(path):
        os.mkdir(path)
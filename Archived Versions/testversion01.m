clc
% addpath('C:\Users\Josh\Dropbox\myvna matlab\AccessMyVNA_0.7\AccessMyVNAdll')
% addpath('D:\ATHENA\Dropbox\myvna_matlab\AccessMyVNA\release')
% load('D:\ATHENA\Dropbox\myvna_matlab\AccessMyVNA\AccessMyVNAdll\stdafx.h')
% [aa,bb]=loadlibrary('C:\Users\Josh\Dropbox\myvna_matlab\release\AccessMyVNAdll.dll','C:\Users\Josh\Dropbox\myvna_matlab\AccessMyVNAdll\AccessMyVNAdll_joshedit.h','alias','test3')
% [aa,bb]=loadlibrary('C:\Users\Josh\Dropbox\myvna_matlab\release\AccessMyVNAdll32.dll','C:\Users\Josh\Dropbox\myvna_matlab\AccessMyVNAdll\AccessMyVNAdll_joshedit.h','alias','test3')

% loadlibrary('D:\ATHENA\Dropbox\myvna matlab\AccessMyVNA_0.7\release\AccessMyVNAdll', 'stdafx.h')
% hfile=fullfile('D:\ATHENA\Dropbox\myvna matlab\AccessMyVNA_0.7\AccessMyVNAdll\AccessMyVNAdll.h')
% loadlibrary('libmx',hfile)

% [aa,bb]=loadlibrary('AccessMyVNAdll32.dll','AccessMyVNAdll_joshedit.h','alias','test')
dll_file='C:\Users\Josh\Desktop\AcessMyVNAv0.7\AccessMyVNAdll\AccessMyVNAdll.dll';
h0_file='C:\Users\Josh\Desktop\AcessMyVNAv0.7\AccessMyVNAdll\stdafx.h';
h_file='C:\Users\Josh\Desktop\AcessMyVNAv0.7\AccessMyVNAdll\AccessMyVNAdll.h';
loadlibrary(dll_file,h0_file,'addheader',h_file);

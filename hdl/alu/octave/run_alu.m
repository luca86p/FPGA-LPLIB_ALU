#!/usr/bin/octave
% =============================================================================
% Whatis        : octave running script for bit-true model of alu_8_16cmd_seq
% Project       : 
% -----------------------------------------------------------------------------
% File          : run_alu.m
% Language      : octave
% Module        : 
% Library       : 
% -----------------------------------------------------------------------------
% Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
%                 
% Company       : 
% Addr          : 
% -----------------------------------------------------------------------------
% Description
% 
% -----------------------------------------------------------------------------
% Dependencies
% 
% -----------------------------------------------------------------------------
% Issues
% 
% -----------------------------------------------------------------------------
% Copyright (c) 2021 Luca Pilato
% MIT License
% -----------------------------------------------------------------------------
% date        who               changes
% 2016-07-01  Luca Pilato       file creation
% =============================================================================

clc
clear
close all

help fun_alu

arg_list = argv();
if nargin()
    N = str2num(arg_list{1});
else
    error ("missing arg");
    exit
endif

if ! ismember(N,2:8)
    error ([num2str(N) " is not in [2:8]"]);
    exit
endif

MAX_UN = 2^N-1;
MIN_UN = 0;
MAX_SG = 2^(N-1)-1;
MIN_SG = -2^(N-1);

% ---- Input
op1 = MIN_UN:MAX_UN;
op2 = MIN_UN:MAX_UN;
cbin = 0:1;

% ---- List of implemented commands to verify
cmd = {'add','addc','sub','subb','mul','and','or','xor','xnor','sll','srl','sra','rl','rlc','rr','rrc'};

% ---- Output preallocation
y = zeros(numel(op1),numel(op2),numel(cbin),numel(cmd));
z = zeros(numel(op1),numel(op2),numel(cbin),numel(cmd));
c = zeros(numel(op1),numel(op2),numel(cbin),numel(cmd));
v = zeros(numel(op1),numel(op2),numel(cbin),numel(cmd));
s = zeros(numel(op1),numel(op2),numel(cbin),numel(cmd));
p = zeros(numel(op1),numel(op2),numel(cbin),numel(cmd));

% ---- Verification
for i_op1 = 1:numel(op1)
    for i_op2 = 1:numel(op2)
        for i_cbin = 1:numel(cbin)
            for i_cmd = 1:numel(cmd)           
                [y(i_op1,i_op2,i_cbin,i_cmd), ...
                 z(i_op1,i_op2,i_cbin,i_cmd), ...
                 c(i_op1,i_op2,i_cbin,i_cmd), ...
                 v(i_op1,i_op2,i_cbin,i_cmd), ...
                 s(i_op1,i_op2,i_cbin,i_cmd), ...
                 p(i_op1,i_op2,i_cbin,i_cmd)] = ...
                 fun_alu(N, op1(i_op1), op2(i_op2), cbin(i_cbin), cmd{i_cmd});
            end
        end
    end
end


% ---- file output write
fname = ["alu_N" num2str(N) "_results.log"];
fid = fopen (fname, "w");
fprintf(fid,"op1 op2 cbin   cmd   y z c v s p\n");
formatSpec = '%3d %3d %4d %5s %3d %1d %1d %1d %1d %1d\n';
for i_op1 = 1:numel(op1)
    for i_op2 = 1:numel(op2)
        for i_cbin = 1:numel(cbin)
            for i_cmd = 1:numel(cmd)
                fprintf(fid, formatSpec, ...
                op1(i_op1), op2(i_op2), cbin(i_cbin), cmd{i_cmd}, ...
                y(i_op1,i_op2,i_cbin,i_cmd), ...
                z(i_op1,i_op2,i_cbin,i_cmd), ...
                c(i_op1,i_op2,i_cbin,i_cmd), ... 
                v(i_op1,i_op2,i_cbin,i_cmd), ...
                s(i_op1,i_op2,i_cbin,i_cmd), ...
                p(i_op1,i_op2,i_cbin,i_cmd));     
            end
        end
    end
end
fclose(fid);

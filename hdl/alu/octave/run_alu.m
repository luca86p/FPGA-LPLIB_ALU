#!/usr/bin/octave

clc
clear
close all

help fun_alu

N = 2;

MAX_UN = 2^N-1;
MIN_UN = 0;
MAX_SG = 2^(N-1)-1;
MIN_SG = -2^(N-1);

% ---- Input
op1 = MIN_UN:MAX_UN;
op2 = MIN_UN:MAX_UN;

% ---- List of implemented commands to verify
cmd = {'add','addc','sub','subb'};


% ---- Output preallocation
res0   = zeros(numel(op1),numel(op2),numel(cmd));
res1   = zeros(numel(op1),numel(op2),numel(cmd));
flags0 = zeros(numel(op1),numel(op2),numel(cmd),5);
flags1 = zeros(numel(op1),numel(op2),numel(cmd),5);


% ---- Verification
for i = 1:numel(op1)
    for ii = 1:numel(op2)
        for iii = 1:numel(cmd)
            [res0(i,ii,iii), z0(i,ii,iii,:), c0(i,ii,iii,:), v0(i,ii,iii,:), s0(i,ii,iii,:), p0(i,ii,iii,:)] = fun_alu(N, op1(i), op2(ii), 0, cmd{iii});
            # cbin = 0
            #[res0(i,ii,iii), flags0(i,ii,iii,:)] = alu(N, op1(i), op2(ii), 0, cmd{iii});
            # cbin = 1
            #[res1(i,ii,iii), flags1(i,ii,iii,:)] = alu(N, op1(i), op2(ii), 1, cmd{iii});
        end
    end
end

% % ---- Debug
% disp('')
% disp(['------ N = ' num2str(N) ' ---------------------------------']);
% fprintf(' cmd  op1 op2 cbin   res    z   c   v   s   p\n');
% fprintf('----------------------------------------------\n');
% formatSpec = '%4s %3d %3d %3d   %4d   %3d %3d %3d %3d %3d\n';

% for iii = 1:numel(cmd)
%   for i = 1:numel(op1)
%       for ii = 1:numel(op2)  
%             fprintf(formatSpec, ...
%                 cmd{iii}, op1(i), op2(ii), 0, res0(i,ii,iii), flags0(i,ii,iii,:));
%             fprintf(formatSpec, ...
%                 cmd{iii}, op1(i), op2(ii), 1, res1(i,ii,iii), flags1(i,ii,iii,:));
%         end
%     end
%     disp('----')
% end
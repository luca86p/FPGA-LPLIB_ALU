function [ y, z, c, v, s, p ] = fun_alu( N, op1, op2, cbin, cmd )
% ALU function for VHDL bit-true verification
%
%   [ y, z, c, v, s, p ] = fun_alu( N, op1, op2, cbin, cmd )
%
%   N        : bit-width (integer)
%   op1, op2 : operands (integer)
%   cbin     : carry/borrow in (integer)
%   cmd      : alu string command e.g. 'add', 'addc', 'sub', 'subb', ...
%   y        : result in integer unsigned representation
%   z, c, v, s, p : flags

% =============================================================================
% Whatis        : octave callable function
% Project       : 
% -----------------------------------------------------------------------------
% File          : fun_alu.m
% Language      : octave
% Module        : fun_alu
% Library       : 
% -----------------------------------------------------------------------------
% Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
%                 
% Company       : 
% Addr          : 
% -----------------------------------------------------------------------------
% Description
%
%   bit-true model of alu_8_16cmd_seq functionalities
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

    MAX_UN = 2^N-1;
    MIN_UN = 0;
    MAX_SG = 2^(N-1)-1;
    MIN_SG = -2^(N-1);

    % range check
    if (op1 > MAX_UN) || (op1 < MIN_SG)
        error('ERROR: op1 not in range');
    elseif (op2 > MAX_UN) || (op2 < MIN_SG)
        error('ERROR: op2 not in range');
    endif

    % unsigned view
    op1_UN = mod(op1, 2^N);
    op2_UN = mod(op2, 2^N);

    % signed view
    if op1>MAX_SG
        op1_SG=op1-2^N; 
    else 
        op1_SG=op1;
    endif
  
    if op2>MAX_SG
        op2_SG=op2-2^N;
    else 
        op2_SG=op2;
    endif

    % flag init
    y = 0;
    z = 0;
    c = 0;
    v = 0;
    s = 0;
    p = 0;

    switch(cmd)

        case {'add'}
            # unconstrained result
            res_UN = op1_UN + op2_UN;
            res_SG = op1_SG + op2_SG;
            # carry flag
            c = res_UN > MAX_UN;
            # c2 overflow falg
            v = res_SG > MAX_SG || res_SG < MIN_SG;
            # N-bit unsigned result
            res_UN = mod(res_UN,2^N);
            # N-bit   signed result
            if res_SG>MAX_SG
              res_SG = res_SG-2^N;
            elseif res_SG<MIN_SG
              res_SG = res_SG+2^N;
            endif
            # zero flag
            z = res_UN == 0;
            # sign flag
            # s = bitand(res_UN, MAX_SG+1)>0;
            s = res_SG < 0;
            # even parity flag
            # p = mod(sum(dec2bin(res_UN)=='1'),2);
            p = mod(sum(dec2bin(res_UN)),2); # ASCII-trick faster

        case {'addc'}
            # unconstrained result
            res_UN = op1_UN + op2_UN + cbin;
            res_SG = op1_SG + op2_SG + cbin;
            # carry flag
            c = res_UN > MAX_UN;
            # c2 overflow falg
            v = res_SG > MAX_SG || res_SG < MIN_SG;
            # N-bit unsigned result
            res_UN = mod(res_UN,2^N);
            # N-bit   signed result
            if res_SG>MAX_SG
              res_SG = res_SG-2^N;
            elseif res_SG<MIN_SG
              res_SG = res_SG+2^N;
            endif
            # zero flag
            z = res_UN == 0;
            # sign flag
            # s = bitand(res_UN, MAX_SG+1)>0;
            s = res_SG < 0;
            # even parity flag
            # p = mod(sum(dec2bin(res_UN)=='1'),2);
            p = mod(sum(dec2bin(res_UN)),2); # ASCII-trick faster

        case {'sub'}
            # unconstrained result
            res_UN = op1_UN - op2_UN;
            res_SG = op1_SG - op2_SG;
            # carry flag
            c = res_UN < MIN_UN;
            # c2 overflow falg
            v = res_SG > MAX_SG || res_SG < MIN_SG;
            # N-bit unsigned result
            res_UN = mod(res_UN,2^N);
            # N-bit   signed result
            if res_SG>MAX_SG
              res_SG = res_SG-2^N;
            elseif res_SG<MIN_SG
              res_SG = res_SG+2^N;
            endif
            # zero flag
            z = res_UN == 0;
            # sign flag
            # s = bitand(res_UN, MAX_SG+1)>0;
            s = res_SG < 0;
            # even parity flag
            # p = mod(sum(dec2bin(res_UN)=='1'),2);
            p = mod(sum(dec2bin(res_UN)),2); # ASCII-trick faster

        case {'subb'}
            # unconstrained result
            res_UN = op1_UN - op2_UN - cbin;
            res_SG = op1_SG - op2_SG - cbin;
            # carry flag
            c = res_UN < MIN_UN;
            # c2 overflow falg
            v = res_SG > MAX_SG || res_SG < MIN_SG;
            # N-bit unsigned result
            res_UN = mod(res_UN,2^N);
            # N-bit   signed result
            if res_SG>MAX_SG
              res_SG = res_SG-2^N;
            elseif res_SG<MIN_SG
              res_SG = res_SG+2^N;
            endif
            # zero flag
            z = res_UN == 0;
            # sign flag
            # s = bitand(res_UN, MAX_SG+1)>0;
            s = res_SG < 0;
            # even parity flag
            # p = mod(sum(dec2bin(res_UN)=='1'),2);
            p = mod(sum(dec2bin(res_UN)),2); # ASCII-trick faster

        case {'mul'}
            # unconstrained result
            res_UN = floor(op1_UN*op2_UN/2^N);
            res_SG = res_UN;
            # N-bit   signed result
            if res_SG>MAX_SG
                res_SG = res_SG-2^N;
            elseif res_SG<MIN_SG
                res_SG = res_SG+2^N;
            endif
            # carry flag
            c = 0;
            # c2 overflow falg
            v = 0;
            # zero flag
            z = res_UN == 0;
            # sign flag
            s = bitget(res_UN, N);
            # even parity flag
            # p = mod(sum(dec2bin(res_UN)=='1'),2);
            p = mod(sum(dec2bin(res_UN)),2); # ASCII-trick faster
          
        case {'and'}
            # unconstrained result
            res_UN = bitand(op1_UN,op2_UN);
            res_SG = res_UN;
            # N-bit   signed result
            if res_SG>MAX_SG
                res_SG = res_SG-2^N;
            elseif res_SG<MIN_SG
                res_SG = res_SG+2^N;
            endif
            # carry flag
            c = 0;
            # c2 overflow falg
            v = 0;
            # zero flag
            z = res_UN == 0;
            # sign flag
            s = bitget(res_UN, N);
            # even parity flag
            # p = mod(sum(dec2bin(res_UN)=='1'),2);
            p = mod(sum(dec2bin(res_UN)),2); # ASCII-trick faster

        case {'or'}
            # unconstrained result
            res_UN = bitor(op1_UN,op2_UN);
            res_SG = res_UN;
            # N-bit   signed result
            if res_SG>MAX_SG
                res_SG = res_SG-2^N;
            elseif res_SG<MIN_SG
                res_SG = res_SG+2^N;
            endif
            # carry flag
            c = 0;
            # c2 overflow falg
            v = 0;
            # zero flag
            z = res_UN == 0;
            # sign flag
            s = bitget(res_UN, N);
            # even parity flag
            # p = mod(sum(dec2bin(res_UN)=='1'),2);
            p = mod(sum(dec2bin(res_UN)),2); # ASCII-trick faster

        case {'xor'}
            # unconstrained result
            res_UN = bitxor(op1_UN,op2_UN);
            res_SG = res_UN;
            # N-bit   signed result
            if res_SG>MAX_SG
                res_SG = res_SG-2^N;
            elseif res_SG<MIN_SG
                res_SG = res_SG+2^N;
            endif
            # carry flag
            c = 0;
            # c2 overflow falg
            v = 0;
            # zero flag
            z = res_UN == 0;
            # sign flag
            s = bitget(res_UN, N);
            # s = bitand(res_UN, 2^(N-1))>0;
            # even parity flag
            # p = mod(sum(dec2bin(res_UN)=='1'),2);
            p = mod(sum(dec2bin(res_UN)),2); # ASCII-trick faster

        case {'xnor'}
            # unconstrained result
            res_UN = bitcmp(bitxor(op1_UN,op2_UN),N);
            res_SG = res_UN;
            # N-bit   signed result
            if res_SG>MAX_SG
                res_SG = res_SG-2^N;
            elseif res_SG<MIN_SG
                res_SG = res_SG+2^N;
            endif
            # carry flag
            c = 0;
            # c2 overflow falg
            v = 0;
            # zero flag
            z = res_UN == 0;
            # sign flag
            s = bitget(res_UN, N);
            # even parity flag
            # p = mod(sum(dec2bin(res_UN)=='1'),2);
            p = mod(sum(dec2bin(res_UN)),2); # ASCII-trick faster

        case {'sll'}
            # unconstrained result
            res_UN = bitshift(op1_UN,1);
            res_SG = res_UN;
            # N-bit unsigned result
            res_UN = mod(res_UN,2^N);
            # N-bit   signed result
            if res_SG>MAX_SG
              res_SG = res_SG-2^N;
            elseif res_SG<MIN_SG
              res_SG = res_SG+2^N;
            endif
            # carry flag
            c = bitget(op1_UN, N);
            # c2 overflow falg
            v = 0;
            # zero flag
            z = res_UN == 0;
            # sign flag
            # s = bitand(res_UN, MAX_SG+1)>0;
            s = res_SG < 0;
            # even parity flag
            # p = mod(sum(dec2bin(res_UN)=='1'),2);
            p = mod(sum(dec2bin(res_UN)),2); # ASCII-trick faster

        case {'srl'}
            # unconstrained result
            res_UN = bitshift(op1_UN,-1);
            res_SG = res_UN;
            # N-bit unsigned result
            res_UN = mod(res_UN,2^N);
            # N-bit   signed result
            if res_SG>MAX_SG
              res_SG = res_SG-2^N;
            elseif res_SG<MIN_SG
              res_SG = res_SG+2^N;
            endif
            # carry flag
            c = bitget(op1_UN, 1);
            # c2 overflow falg
            v = 0;
            # zero flag
            z = res_UN == 0;
            # sign flag
            # s = bitand(res_UN, MAX_SG+1)>0;
            s = res_SG < 0;
            # even parity flag
            # p = mod(sum(dec2bin(res_UN)=='1'),2);
            p = mod(sum(dec2bin(res_UN)),2); # ASCII-trick faster

        case {'sra'}
            # unconstrained result
            res_UN = bitor(bitshift(op1_UN,-1), bitand(op1_UN, 2^(N-1)));
            res_SG = res_UN;
            # N-bit unsigned result
            res_UN = mod(res_UN,2^N);
            # N-bit   signed result
            if res_SG>MAX_SG
              res_SG = res_SG-2^N;
            elseif res_SG<MIN_SG
              res_SG = res_SG+2^N;
            endif
            # carry flag
            c = bitget(op1_UN, 1);
            # c2 overflow falg
            v = 0;
            # zero flag
            z = res_UN == 0;
            # sign flag
            # s = bitand(res_UN, MAX_SG+1)>0;
            s = res_SG < 0;
            # even parity flag
            # p = mod(sum(dec2bin(res_UN)=='1'),2);
            p = mod(sum(dec2bin(res_UN)),2); # ASCII-trick faster
                
        case {'rl'}
            # unconstrained result
            res_UN = bitshift(op1_UN,1) + bitget(op1_UN, 2^(N-1));
            res_SG = res_UN;
            # N-bit unsigned result
            res_UN = mod(res_UN,2^N);
            # N-bit   signed result
            if res_SG>MAX_SG
              res_SG = res_SG-2^N;
            elseif res_SG<MIN_SG
              res_SG = res_SG+2^N;
            endif
            # carry flag
            c = 0;
            # c2 overflow falg
            v = 0;
            # zero flag
            z = res_UN == 0;
            # sign flag
            # s = bitand(res_UN, MAX_SG+1)>0;
            s = res_SG < 0;
            # even parity flag
            # p = mod(sum(dec2bin(res_UN)=='1'),2);
            p = mod(sum(dec2bin(res_UN)),2); # ASCII-trick faster

        case {'rlc'}
            # unconstrained result
            res_UN = bitshift(op1_UN,1) + cbin;
            res_SG = res_UN;
            # N-bit unsigned result
            res_UN = mod(res_UN,2^N);
            # N-bit   signed result
            if res_SG>MAX_SG
              res_SG = res_SG-2^N;
            elseif res_SG<MIN_SG
              res_SG = res_SG+2^N;
            endif
            # carry flag
            c = bitget(op1_UN, N);
            # c2 overflow falg
            v = 0;
            # zero flag
            z = res_UN == 0;
            # sign flag
            # s = bitand(res_UN, MAX_SG+1)>0;
            s = res_SG < 0;
            # even parity flag
            # p = mod(sum(dec2bin(res_UN)=='1'),2);
            p = mod(sum(dec2bin(res_UN)),2); # ASCII-trick faster

        case {'rr'}
            # unconstrained result
            res_UN = bitshift(op1_UN,-1) + 2^(N-1)*bitget(op1_UN, 1);
            res_SG = res_UN;
            # N-bit unsigned result
            res_UN = mod(res_UN,2^N);
            # N-bit   signed result
            if res_SG>MAX_SG
              res_SG = res_SG-2^N;
            elseif res_SG<MIN_SG
              res_SG = res_SG+2^N;
            endif
            # carry flag
            c = 0;
            # c2 overflow falg
            v = 0;
            # zero flag
            z = res_UN == 0;
            # sign flag
            # s = bitand(res_UN, MAX_SG+1)>0;
            s = res_SG < 0;
            # even parity flag
            # p = mod(sum(dec2bin(res_UN)=='1'),2);
            p = mod(sum(dec2bin(res_UN)),2); # ASCII-trick faster

        case {'rrc'}
            # unconstrained result
            res_UN = bitshift(op1_UN,-1) + 2^(N-1)*cbin;
            res_SG = res_UN;
            # N-bit unsigned result
            res_UN = mod(res_UN,2^N);
            # N-bit   signed result
            if res_SG>MAX_SG
              res_SG = res_SG-2^N;
            elseif res_SG<MIN_SG
              res_SG = res_SG+2^N;
            endif
            # carry flag
            c = bitget(op1_UN, 1);
            # c2 overflow falg
            v = 0;
            # zero flag
            z = res_UN == 0;
            # sign flag
            # s = bitand(res_UN, MAX_SG+1)>0;
            s = res_SG < 0;
            # even parity flag
            # p = mod(sum(dec2bin(res_UN)=='1'),2);
            p = mod(sum(dec2bin(res_UN)),2); # ASCII-trick faster

    otherwise
        disp(["ERROR: cmd '" cmd "' not recognised"]);
        return
  
  endswitch

  y = res_UN;

  disp("");
  disp(  ["cmd   = " cmd]);
  disp(  ["cbin  = " num2str(cbin)']);
  printf(["op1   = " dec2bin(op1_UN,N) "     op1_UN:%6d    op1_SG:%6d\n"], op1_UN, op1_SG);
  printf(["op2   = " dec2bin(op2_UN,N) "     op2_UN:%6d    op2_SG:%6d\n"], op2_UN, op2_SG);
  printf(["res   = " dec2bin(res_UN,N) "     res_UN:%6d    res_SG:%6d\n"], res_UN, res_SG);
  disp([  "zcvsp = " num2str(z) " " num2str(c) " " num2str(v) " " num2str(s) " " num2str(p)]);

endfunction


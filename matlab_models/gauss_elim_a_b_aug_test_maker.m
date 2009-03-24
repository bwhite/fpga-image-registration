for i=0:5
    for j=0:6
        if j < 6
            disp(sprintf('aug(%d)(%d) <= to_signed(16#%s#,27);',i,j,hex(sA(i+1,j+1))))
        else
            disp(sprintf('aug(%d)(%d) <= to_signed(16#%s#,27);',i,j,hex(sb(i+1))))
        end
    end
end
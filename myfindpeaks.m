function [vals, pk] = myfindpeaks(frame)
  vals = [];
  pk = [];
  for n = 1 : length(frame)
    yes = 0;
    if 1 == n
      if frame(1) > frame(2)
         yes = 1;
      end
    elseif length(frame) == n
      if frame(n) > frame(n - 1)
          yes = 1;
      endif
    elseif frame(n) >= frame(n - 1) && frame(n) > frame(n + 1)
      yes = 1;
    endif
    if yes
      vals(end + 1) = frame(n);
      pk(end + 1) = n;
    endif
  endfor
endfunction

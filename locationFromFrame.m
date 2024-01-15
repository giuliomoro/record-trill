function [location, y, polyX, polyY, count] = locationFromFrame(frame)
    [vals, pk] = myfindpeaks(frame);
    if length(pk) < 1
      location = 0;
      y = 0;
      polyX = 0;
      polyY = 0;
      count = 0;
      return;
    endif
    % use highest peak only (only one touch will be detected)
    [~, M] = max(vals);
    pk = pk(M);
    polyIdx = [pk];
    threshold = 0;
    % look both ways to determine what pads are part of the touch
    doneBelow = 0;
    for n = (pk - 1) : -1 : 1
      if (frame(n) > threshold)
        polyIdx(end + 1) = n;
        doneBelow = 1;
      else
        break
      endif
    endfor
    doneAbove = 0;
    for n = (pk + 1) : length(frame)
      if (frame(n) > threshold)
        polyIdx(end + 1) = n;
        doneAbove = 1;
      else
        break
      endif
    endfor
    polyIdx = sort(polyIdx);
    count = length(polyIdx);
    % ensure we have at least three pads, adding above and/or below as needed
    while length(polyIdx) < 3
      if(~doneBelow)
        doneBelow = 1;
        polyIdx(end + 1) = min(polyIdx) - 1;
      endif
      if(~doneAbove)
        doneAbove = 1;
        polyIdx(end + 1) = max(polyIdx) + 1;
      endif
    endwhile
    polyIdx = sort(polyIdx);
    pts = [];
    for n = 1 : length(polyIdx)
      idx = polyIdx(n);
      if idx < 1
        val = 0;
      elseif idx > length(frame)
        val = 0;
      else
        val = frame(idx);
      endif
      pts(n) = val;
    endfor
    P = polyfit(polyIdx, pts, 2);
    polyX = polyIdx(1) : 0.001 : polyIdx(end);
    polyY = polyval(P, polyX);
    [y, Mx] = max(polyY); % quick and dirty max
    location = polyX(Mx);
end

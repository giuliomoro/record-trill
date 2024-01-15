set(0, 'DefaultAxesFontSize', 13);

compute = 0;
basePlot = 0;
animation = 1;
% save the file from the IDE in the same folder as this file, then put
% its filename (without .m) below so that it gets executed and it loads the
% file's content in the `data` variable
if compute % compute
bar_raw_mult11_bits12_pres3_thr40

data = data(2:end, :); % remove the first line, as it's garbage

t = data(:,1); % timestamps
p = data(:,2) * 29 / 26; % position
s = data(:,3); % size, unused
rawdata = max(0, data(:, 4:end) - 40/4096); % if LOG_RAW was defined, these will be the readings from the individual pads.
numPads = 26;
rawdata = rawdata(:, 1:numPads);

pp = nan(size(p)); % polynomial location detection
counts = nan(size(p));
szs = nan(size(p));
for n = 1 : length(pp)
  [location, ~, ~, ~, counts(n), szs(n)] = locationFromFrame(rawdata(n, :));
  pp(n) = (location - 1) / numPads;
end
pprad = pp * 2 * pi;
prad = p * 2 * pi;
endif % compute
%%
if basePlot %base plot
figure(1)
plotSine = 0;
if(plotSine)
    plot(t, sin(prad), '.-')
    hold on
    plot(t, sin(pprad), '.-')
    hold off
    ylim([0 1])
    ylabel('sin(2\pi x)')
else
    T = 1:length(t);
    plot(T, p, '.-')
    hold on
    plot(T, pp, '.-')
    hold off
    ylim([0 1])
    ylabel('x')
end
title('Temporal evolution')
xlabel('Time(s)')
legend('Trill Centroid', 'Parabolic location')
end % base plot
%%
if animation % animation:
% manually set the ranges of an interval (in seconds) that you want to
% compare
tstart = 2;
tend = 2.4;
% also set what pads and vertical ranges to focus on
padstart = 16;
padend = 24;
ystart = 0;
yend = 1;
idxs = find(t > tstart & t < tend);

figure(2)
for k = 1:1 % set to 1:5 or similar if you want the animation to loop.
    for n = idxs(1):idxs(end)
        clf
        subplot(2,1,1)
%        set(gca, 'Position', get(gca, 'Position') + [0 0.24 0 -0.2])
        plot(t, p, '.-')
        hold on
        plot(t, pp, '.-')
        line([t(n) t(n)], [0 1], 'Color', 'k')
        hold off
        ylabel('x')
        xlabel('Time(s)')
        xlim([tstart, tend])
        ylim([min([p(idxs);pp(idxs)]), max([p(idxs);pp(idxs)])])
        legend('Trill Centroid', 'Parabolic location', 'Current')
        legend('Location', 'NorthEastOutside')
        subplot(2,1,2)
%        set(gca, 'Position', get(gca, 'Position') + [0 0 0 0.28])
        hold on
        frame = rawdata(n, :);
        x = 1:length(frame);
        pos = p(n) * x(end) + 1;
        plot(x, frame, 'Color', 'k', 'LineStyle', '-', 'Marker', '.', 'MarkerSize', 10);
        stem(pos, yend - 0.03, 'Color', 'k');
        text(padstart, yend + 0.03, sprintf('Frame %d (time %.3f)', n, t(n)), 'FontSize', 20);
        [polyLocation, polyMax, polyX, polyY] = locationFromFrame(frame);
        plot(polyX, polyY, 'Color', 'r');
        stem(polyLocation, yend - 0.05, 'Color', 'r');

        legend('readings', 'centroid', 'parabolic fit', 'parabolic max')
        legend('Location', 'NorthEastOutside')
        xlim([padstart - 0.5, padend + 0.5])
        ylim([ystart, yend])
 %       set(gca, 'XTick', padstart : padend)
        xlabel('Pad')
        ylabel('Activation(rel)')
        hold off
        % uncomment this to export each frame as an image
        print('-dpng', '-r100', sprintf('frame_%d', n))
    end
end
end % if animation
%%

if 0
figure(3)
plot(p, sin(prad), '.')
title('Mapping x to sin(x)')
xlim([0 1])
ylim([-1 1])
xlabel('x Position (relative)')
ylabel('sin(2\pi x)')
end
if 0
% % "Trill touch locations (between 0 & 1) plotted against the diff(y-coordinates)." (actually the other way around)
figure(4)
plot(p(1:end-1), diff(sin(prad)), '.-')
title('Position-dependent variations')
xlim([0 1])
ylim([-0.2 0.2])
xlabel('x Position (relative)')
ylabel('\Delta sin(2\pi x)')
% xlim([0 1])
end

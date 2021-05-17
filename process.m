set(0, 'DefaultAxesFontSize', 18);
% close all

% save the file from the IDE in the same folder as this file, then put
% its filename (without .m) below so that it gets executed and it loads the
% file's content in the `data` variable

ring_raw_mult11_bits10_pres2
ring_raw_mult7_bits10_pres2
data = data(2:end, :); % remove the first line, as it's garbage

t = data(:,1); % timestamps
p = data(:,2); % position
s = data(:,3); % size, unused
rawdata = data(:, 4:end); % if LOG_RAW was defined, these will be the readings from the individual pads.
rawdata = rawdata(:, 1:28); % only 28 pads for ring

pp = nan(size(p)); % polynomial location detection
for n = 1 : length(pp)
    pp(n) = (locationFromFrame(rawdata(n, :)) - 1) / 28;
end
pprad = pp * 2 * pi;
prad = p * 2 * pi;
%%
figure(1)
plotSine = 1;
if(plotSine)
    plot(t, sin(prad), '.-')
    hold on
    plot(t, sin(pprad), '.-')
    hold off
    ylim([0 1])
    ylabel('sin(2\pi x)')
else
    plot(t, p, '.-')
    hold on
    plot(t, pp, '.-')
    hold off
    ylim([0 1])
    ylabel('x')
end
title('Temporal evolution')
xlabel('Time(s)')
legend('Trill Centroid', 'Parabolic location')
%%
if 1 % animation:
% manually set the ranges of an interval (in seconds) that you want to
% compare
tstart = 4.9;
tend = 5;
% also set what pads and vertical ranges to focus on
padstart = 10;
padend = 16;
ystart = 0;
yend = 0.55;
idxs = find(t > tstart & t < tend);

figure(2)
for k = 1:1 % set to 1:5 or similar if you want the animation to loop.
    for n = idxs(1):idxs(end)
        clf
        subplot(2,1,1)
        g = gca;
        g.Position = g.Position + [0 0.24 0 -0.2];
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
        g = gca;
        g.Position = g.Position + [0 0 0 0.28];
        hold on
        frame = rawdata(n, :);
        x = 1:length(frame);
        pos = p(n) * x(end) + 1;
        plot(x, frame, 'Color', 'k', 'LineStyle', '-', 'Marker', '.', 'MarkerSize', 10);
        stem(pos, yend - 0.03, 'Color', 'k');
        text(padstart, yend - 0.03, sprintf('Frame %d (time %.3f)', n, t(n)), 'FontSize', 20);
        [polyLocation, polyMax, polyX, polyY] = locationFromFrame(frame);
        plot(polyX, polyY, 'Color', 'r');
        stem(polyLocation, yend - 0.05, 'Color', 'r');

        legend('readings', 'centroid', 'parabolic fit', 'parabolic max')
        legend('Location', 'West')
        xlim([padstart - 0.5, padend + 0.5])
        ylim([ystart, yend])
        set(gca, 'XTick', padstart : padend)
        xlabel('Pad')
        ylabel('Activation(rel)')
        hold off
        % uncomment this to export each frame as an image
        % print('-dpng', '-r100', sprintf('frame %d', n))
        pause(0)
    end
end
end % if animation
%%
figure(3)
plot(p, sin(prad), '.')
title('Mapping x to sin(x)')
xlim([0 1])
ylim([-1 1])
xlabel('x Position (relative)')
ylabel('sin(2\pi x)')

% % "Trill touch locations (between 0 & 1) plotted against the diff(y-coordinates)." (actually the other way around)
figure(4)
plot(p(1:end-1), diff(sin(prad)), '.-')
title('Position-dependent variations')
xlim([0 1])
ylim([-0.2 0.2])
xlabel('x Position (relative)')
ylabel('\Delta sin(2\pi x)')
% xlim([0 1])

function [location, y, polyX, polyY] = locationFromFrame(frame)
    [vals, pk] = findpeaks(frame);
    % use highest peak only (only one touch will be detected)
    [~, M] = max(vals);
    pk = pk(M);
    polyIdx = pk - 1 : pk + 1;
    if(length(polyIdx) < 3 || polyIdx(1) <= 0 || polyIdx(end) >= length(frame))
        % TODO: add proper handling when we are close to the edge or
        % wraparound point
        location = 0;
        y = 0;
        polyX = 0;
        polyY = 0;
        return;
    end
    polyX = polyIdx(1) : 0.001 : polyIdx(end);
    P = polyfit(polyIdx, frame(polyIdx), 2);
    polyY = polyval(P, polyX);
    [y, Mx] = max(polyY); % quick and dirty max
    location = polyX(Mx);
end
set(0, 'DefaultAxesFontSize', 18);
% close all

% save the file from the IDE in the same folder as this file, then put
% its filename (without .m) below so that it gets executed and it loads the
% file's content in the `data` variable

% ring_raw_mult11_bits10_pres2
ring_raw_mult7_bits10_pres2

t = data(:,1); % timestamps
p = data(:,2); % position
s = data(:,3); % size, unused
rawdata = data(:, 4:end); % if LOG_RAW was defined, these will be the readings from the individual pads.

prad = p * 2 * pi;

figure(1)
plot(t(2:end), sin(prad(2:end)), '.-')
% plot(t, p, '.-')
title('Temporal evolution')
ylim([-1 1])
xlabel('Time(s)')
ylabel('sin(2\pi x)')
%%
figure(2)
plot(p, sin(prad), '.')
title('Mapping x to sin(x)')
xlim([0 1])
ylim([-1 1])
xlabel('x Position (relative)')
ylabel('sin(2\pi x)')

% % "Trill touch locations (between 0 & 1) plotted against the diff(y-coordinates)." (actually the other way around)
figure(3)
plot(p(1:end-1), diff(sin(prad)), '.-')
title('Position-dependent variations')
xlim([0 1])
ylim([-0.2 0.2])
xlabel('x Position (relative)')
ylabel('\Delta sin(2\pi x)')
% xlim([0 1])
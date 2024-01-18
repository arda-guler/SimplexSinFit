positions = [];
times = [];
Hz = 2;
cycle_time = 1/Hz;
sim_time = 0;
sim_dt = 1/9600;
amplitude = 5;
position = 0;
% vel = 0;

fitDataPts = (9600 / Hz) * 3;

cycle_num = 0;
while cycle_num < 1e5
    angle = mod(sim_time, cycle_time) * 360 * Hz; % + 90; (random shift)
    position = sind(angle) * amplitude + (rand() - rand()) * 0.2 * amplitude;
    
    positions = [positions; position];
    times = [times; sim_time];

    % we have enough data pts to make a sine fit
    if (cycle_num > fitDataPts) && mod(cycle_num, 1000) == 0
        startIdx = max(1, numel(positions) - fitDataPts + 1);
        endIdx = numel(positions);

        pos_subset = positions(startIdx:endIdx);
        time_subset = times(startIdx:endIdx);

        ymax = max(pos_subset);
        ymin = min(pos_subset);

        mag = (ymax - ymin) * 0.5;
        
        sign_change_positions = [];
        cycle_since_last_change = 0;
        for i = 2:length(pos_subset)
            if sign(pos_subset(i-1)) ~= sign(pos_subset(i)) && cycle_since_last_change > 500
                sign_change_positions = [sign_change_positions; time_subset(i)];
                cycle_since_last_change = 0;
            end

            cycle_since_last_change = cycle_since_last_change + 1;
        end

        timedelta = sign_change_positions(3) - sign_change_positions(1);
        freqHz = 1/timedelta;

        clc;
        fprintf('a = %.4f\n', mag);
        fprintf('b = %.4f\n', freqHz);
    end

    sim_time = sim_dt * cycle_num;
    cycle_num = cycle_num + 1;
end

sinfity = mag * sind(freqHz * 360 * times);
hold on;
plot(times, positions);
plot(times, sinfity);
hold off;


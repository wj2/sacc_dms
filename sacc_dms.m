%% Editable during task
editable('fix_window_radius_ms','target_window_radius', 'target_fix_time','time_to_saccade','num_rewards_ms','reward_dur','radius','fix_hpos_ms','fix_vpos_ms','vis_threshold')

%% Variables

wait_for_fix_ms = 5000;
fixation_time_ms = 500;
fix_window_radius_ms = 2;
initial_fix_ms = 150;

target_time = 300; %target flashes up for this long before delay
time_to_saccade = 500; %has this much time to make saccade to target location % 500
target_fix_time = 150; %has to look at the target location for this long after he saccades to it %150
target_window_radius = 3; %4
delay_time_ms = 1000;

set_iti(900);

samp_x = 0;
samp_y = 0;

test_x = 4;
test_y = 4;

num_rewards_ms = 1;
reward_dur = 130;

%% codes
fix_on = 35;
fix_off = 36;
fix_acq = 8;

samp_on = 25;
samp_off = 26;
reward_given = 96;

break_fix = 3;
no_fix = 4;
incorr_resp = 6;
correct = 0;

%% stim changes
fix_dot = 1;
samp_stim = 2;
dist_stim = 3;
cond = TrialRecord.CurrentCondition;
if cond == 1 || cond == 3
    test_stim = samp_stim;
    alt_stim = dist_stim;
elseif cond == 2 || cond == 4
    test_stim = dist_stim;
    alt_stim = samp_stim;
end

test_alt_x = -test_x;
test_alt_y = -test_y;
reposition_object(samp_stim, samp_x, samp_y);

toggleobject(fix_dot, 'eventmarker', fix_on); % turn on fix spot, start wait fixation

[ontarget, rt] = eyejoytrack('acquirefix',[1],[fix_window_radius_ms], wait_for_fix_ms); %acquire fix, stay w/in fix window

eventmarker(12);    %end wait fixation

if ~ontarget(1),% doesn't fixate within wait_for_fix
    trialerror(no_fix); %no fixation
    rt=NaN;
    toggleobject(fix_dot,'eventmarker',fix_off); % turn off fix spot
    return
end

eventmarker(fix_acq); %fixation occurs

[ontarget, rt] = eyejoytrack('holdfix',[1],[fix_window_radius_ms], initial_fix_ms); %in case he's on border of fix window,

if ~ontarget(1),
end

[ontarget, rt] = eyejoytrack('holdfix',[1],[fix_window_radius_ms], fixation_time_ms);% maintain fix w/in fix window for duration of fixation_time

if ~ontarget(1), %if break fix
    trialerror(break_fix); %break fixation
    rt=NaN;
    toggleobject(fix_dot,'eventmarker',fix_off); % turn off fix spot, broke fixation
    return
end

% if fixates for specified time,

toggleobject(samp_stim,'eventmarker',samp_on); % turn on target at (new_xpos, new_ypos)

[ontarget, rt] = eyejoytrack('holdfix',[1],[fix_window_radius_ms], target_time); %maintain fix while target flashes

if ~ontarget(1),
    trialerror(break_fix); %break fixation
    rt=NaN;
    toggleobject(fix_dot,'eventmarker',fix_off); %turn off fix spot, broke fixation
    toggleobject(samp_stim,'eventmarker',samp_off);  %turn off target
    return
end

toggleobject(samp_stim,'eventmarker',samp_off);  %turn off target

% delay period : fix spot on, target off
[ontarget, rt] = eyejoytrack('holdfix',[1],[fix_window_radius_ms],delay_time_ms);

if ~ontarget(1),
    trialerror(break_fix); %break fixation
    rt=NaN;
    toggleobject(fix_dot,'eventmarker',fix_off); % turn off fix spot, broke fixation
    return
end

reposition_object(test_stim, test_x, test_y);
reposition_object(alt_stim, test_alt_x, test_alt_y);
toggleobject([test_stim alt_stim], 'eventmarker', testsamp_on);
[ontarget, rt] = eyejoytrack('holdfix', [fix_dot], [fix_window_radius_ms], decision_time);
if ~ontarget(1)
    trialerror(break_fix);
    rt = NaN;
    toggleobject(fix_dot, 'eventmarker', fix_off);
    toggleobject([test_stim alt_stim], 'eventmarker', testsamp_off);
    return
end
toggleobject(fix_dot,'eventmarker',fix_off); % turn off fix spot ->this is cue for monkey to make saccade

[ontarget, rt] =  eyejoytrack('acquirefix',[test_stim],[target_window_radius], time_to_saccade);
if ~ontarget(1)
    trialerror(incorr_resp);
    rt = NaN;
    return
end
[ontarget, rt] = eyejoytrack('holdfix', [test_stim], [target_window_radius], target_fix_time);
toggleobject([test_stim alt_stim], 'eventmarker', testsamp_off);
if ~ontarget(1)
    trialerror(incorr_resp);
    rt = NaN;
    return
end
goodmonkey(reward_dur);
eventmarker(reward_given);
trialerror(correct);
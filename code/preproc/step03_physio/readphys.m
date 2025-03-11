%	to open physiological data file and do some plotting of
%	of the ppg and respiratory data.  
%	
%	rev 0 	11/3/99		original from motplot
%	rev 1 	12/7/99		does the resp phase from peaks
%	rev 2 	12/14/99	calculates running HR, resp rate, and
%				breath volume
%				makes an output for each acquisition
%	rev 3 	1/25/00		makes an output every desired TR
%	rev 11 	2/21/04		to read file from excite physio
%	rev 12 	2/25/04		file has trig time pts and then resp waveform
%				trig table is terminated by -9999 entry
%		2/14/05		changed the resp threshold and made the
%				output in resp rate rather then interval
%		7/26/05		fix odd factor of two in the 'ignore time'
%		9/3/07		add rvt plot, a la R. Birn.
%	rev 20  5/1/08		20x samples PPG at 10 ms, resp at 40ms
%		5/25/08		use the initial 30s to set up the convolver
%		8/4/08          offset time start as Tscan - nframes*TR
%                               because start of record not tied to scan start
%	rev 22  5/1/11		22x has PPG waveform too
%	rev 24  1/14/14		24X
%	       //20/20		add avehr, avebr to plots
%		4/3/21		fix extra TR at end of physio
%      readphy	8/16/21		add plot of rrate and hrate with task block

clear; 
kern2 = [19:-1:-19];

PRESC = 30.0;		% seconds of prepended data
dtr = 0.040;		% in seconds
dth = 0.010;		% in seconds
Twin = 6;		% integration window

%  open the input file

fname = input('gimme file = ', 's');
fid = fopen(fname, 'r');
[dat nf] = fscanf(fid, '%g\n');
fclose(fid);

foo = input('gimme [nframes TR(s)] = ');
nframes = foo(1);  TR = foo(2);
Tscan = nframes*TR;
Tsart = (nframes+1)*TR;	% extra sample at end 

% parse the triggers and resp waveform

ntrig = find(dat == -9999)-1;
etrig = dat(1:ntrig)*dth;	% trigger times
ppgloc = find(dat == -8888)-1;
respr = dat(ntrig+2:ppgloc);	% resp waveform
ppgwave = dat(ppgloc+2:end);	% ppg waveform

nresp = length(respr);
ne = length(etrig);
averr = (etrig(ne) - etrig(1))/ne;
avehr = 60/averr;		% BPM
fprintf('average HR = %d BPM\n', fix(avehr));

% check for missing or too many trigs

faverr = .35*averr;

trig(1) = etrig(1);
k = 1;
for j=2:ne
  k = k +1;
  trig(k) = etrig(j);
  if(abs(etrig(j) - etrig(j-1) - averr) < faverr)
      break;
  end
end
i = j;
while(i<=ne)
  dif = etrig(i) - trig(k-1) - averr;
  if(abs(dif) < faverr)
    trig(k) = etrig(i);
    %fprintf('i k dif trigk ok %d %d %f %f\n', i, k, dif, trig(k));
    k = k + 1;
    i = i + 1;
  elseif (dif > faverr)
    trig(k) = trig(k-1) + averr;
    %fprintf('i k dif trigk long %d %d %f %f\n', i, k, dif, trig(k));
    k = k + 1;
  else
    %fprintf('i k dif short %d %d %f\n', i, k, dif);
    i = i + 1;	
  end
end
etrig = trig;
ne = k - 1;

ts = nresp*dtr;	% sampled time
time0 = ts - Tsart;		% how much to ignore
fprintf('start time = %.3f\n', time0 - PRESC);
if(time0 < 0)
  fprintf('Eek!  Not enough data- I give up!\n');
  return
end

Tout = input('output sample interval, s [2s]) = ');
if(isempty(Tout))
  Tout = 2;
end
nout = fix(Tscan/Tout);
time = (0:nout-1)*Tout;
fprintf('num output samples = %d\n', nout);

% find ecg intvl for each cardiac cycle and thence hrate

clear hrate;
for j=1:nout
  t = time0 + time(j);
  i1 = 1; i2 = 1;
  for i1=1:ne
    if(etrig(i1)>=t-Twin*.5)
      break;
    end
  end
  for i2=i1:ne
    if(etrig(i2)>t+Twin*.5)
      break;
    end
  end
  i2 = i2 - 1;
  if(i2 == i1)              % end of trace
    i1= i1 - 1;
  end
  hrate(j) = (i2-i1)*60/(etrig(i2) - etrig(i1));       % bpm 
end

figure(1)
subplot(2,2,1); 
plot(time, hrate);grid
ylabel('hrate, BPM');
xlabel('time, s');
title(sprintf('%s  avehr = %5.1f',fname,avehr));

% get HRV

Nbeats = 10;			% num heartbeats in calc
N2 = Nbeats/2;
RR = [diff(etrig) 0];		% rr interval, s
for j=N2+1:ne -N2
  rrstd(j) = std(RR(j-N2:j+N2));
end
hrvraw = 1./rrstd;		
hrv = interp1(etrig(1:ne-N2),hrvraw,time);

subplot(2,2,2); 
plot(time, hrv);grid
ylabel('HRV, Hz');
xlabel('time, s');

%  now do the resp.  find the peaks

respx = max(respr);
respn = min(respr);
resp = 100*(respr - respn)/(respx - respn);
n1 = fix(time0/dtr);
%subplot(2,2,2); 
%plot((1:nresp-n1+1)*dtr, resp(n1:nresp));grid
%ylabel('respiration'); 
%xlabel('time, s');

drdt = conv(resp, kern2);
drdt = drdt(19:nresp+18);
d2rdt2 = conv(drdt, kern2);
d2rdt2 = d2rdt2(19:nresp+18);
rpeak = (d2rdt2 > 0.5e-6);  	% nice threshold

% find the resp trigs

nr = 0; 
for (j=2:nresp)
  if (rpeak(j)==1 & rpeak(j-1)==0)  % first only
    nr = nr + 1;
    rtrig(nr) = j*dtr;
  end
end
averesp = (rtrig(nr) - rtrig(1))/nr;
averrate = 60/averesp;		% breaths/min
fprintf('average resp = %d breaths/min\n', fix(averrate));

% find resp intvl for each breath

resptime = diff(rtrig);
nrespt = nr - 1;
tresptime = (rtrig(1:nrespt) + rtrig(2:nr))*.5;
respintvl = spline(tresptime, resptime, time+time0);
rrate = 60./respintvl;
avebr = mean(rrate);
subplot(2,2,3); 
plot(time, rrate);grid
ylabel('resp rate, BrPM');
xlabel('time, s');
title(sprintf('avebr = %5.1f',avebr));

% plot rv(t)

clear rv;
for j = 1:nout
  t = time0 + time(j);
  i1 = fix((t - Twin*.5)/dtr);
  i2 = min(nresp, fix(t + Twin*.5)/dtr);
  rv(j) = std(resp(i1:i2));
end
subplot(2,2,4); 
plot(time, rv);  grid
ylabel('RV')
xlabel('time, s');
  
%  plot vs task

tperiod = input('plot design period (frames) (cr for none) = ');
if(~isempty(tperiod))
  figure(2);
  dd = sqwave(nout,tperiod);
  t = 1:nout;
  subplot(2,1,1)
  plot(t,hrate,'b',t,avehr+2*dd,'r');
  grid
  xlabel('Time frame');
  ylabel('Heart rate, BPM');
  legend('meas','design');
  X=corrcoef(dd,hrate);
  title(sprintf('%s  avehr = %5.1f   r = %5.3f', fname,avehr,X(1,2)));
  subplot(2,1,2)
  plot(t,rrate,'b',t,averrate+3*dd,'r');
  grid
  xlabel('Time frame');
  ylabel('Resp rate, BPM');
  legend('meas','design');
  X=corrcoef(dd,rrate);
  title(sprintf('avebr = %5.1f  r = %5.3f', avebr, X(1,2)));
end

% save the output

fnout = input('output file [cr for default, s for none]= ', 's');
if(isempty(fnout))
  fnout = sprintf('%s.out',fname);
elseif(strcmp(fnout, 's'))
  return;
end
fout = fopen(fnout, 'w');
%fprintf(fout, '%f  %f %f %f\n', [hrate', rrate', hrv', rv']');
fprintf(fout, '%f  %f\n', [hrate', rrate']');
fclose(fout); 
fprintf('wrote file  %s\n', fnout);

function dd = sqwave(nframes,period,delay)
% makes a sqare wave of unity amplitude
% delay is optional
      
  if ~exist('delay','var')
    delay = 0;
  end
  t=1:nframes;
  d = sin(2*pi*t/period);
  dd = double(d<0);
  if(delay~=0)
    dd = [zeros(1,delay) dd(1:nframes-delay)];
  end  ;
end


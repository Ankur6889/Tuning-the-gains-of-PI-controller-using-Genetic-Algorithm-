%
% Simulation model for a PI controller.
%
% Z = evaluateControlSystem(X);
%
% Input:  X - a sampling plan
%             (one design per row, one design variable per column)
% Output: Z - performance evaluations
%             (one design per row, one criterion per column;
%              criteria are...
%              1: maximum closed-loop pole magnitude
%              2: gain margin
%              3: phase margin
%              4: 10-90% rise time
%              5. peak time
%              6. overshoot (% points)
%              7. undershoot (% points)
%              8. 2% settling time
%              9. steady-state error (% points))
%
function Z = optimizeControlSystem(X);

[noInds, noVar] = size(X);

Z =[];

warning off

for ind = 1:noInds
  % Extract the candidate controller gains.
  kp=X(ind,1);
  ki=X(ind,2);
    
  % Form the open-loop transfer function.
  olNum = [(kp+ki)*(1-exp(-1)) ...
           -kp*(1-exp(-1))];
  
  olDen = [1 ...
           -1-exp(-1) ...
           exp(-1) ...
           0 ...
           0];
  
  % Form the closed-loop transfer function.
  clNum=[(1-exp(-1))*(kp+ki) ...
         -(kp/(kp+ki))*(1-exp(-1))*(kp+ki)];
  clDen=[1 ...
         -(1+exp(-1)) ...
         exp(-1) ...
         (1-exp(-1))*(kp+ki) ...
	 -(kp/(kp+ki))*(1-exp(-1))*(kp+ki)];
 
  % Get stability measure.
  sPoles = roots(clDen);
  clStable = max(abs(sPoles));
      
  olTF = tf(olNum, olDen, 1.0);
  
  [gainMargin, phaseMargin, wcGP, wcPM] = margin(olTF);
  
  % Do a unit step response.
  timeData = [0:1:100];
  outputData = dstep(clNum, clDen, timeData);
  
  % Collect results where possible (stable).
  if clStable < 1
    riseTime = getRiseTime(timeData, outputData, outputData(end));
    settleTime = getSettlingTime(timeData, outputData, 0.02, ...
						outputData(end));
  else
    riseTime = getRiseTime(timeData, outputData, 1.0);
    settleTime = getSettlingTime(timeData, outputData, 0.02, 1.0);
  end
  [overshoot, overTime, undershoot, underTime] = getShoots(timeData, outputData);
  ssError = getSSError(outputData);
 


  % Assign to output variable.
  if clStable>1 || isnan(clStable) || isnan(gainMargin) || isnan(phaseMargin) || isnan(riseTime) || isnan(overTime) || isnan(overshoot) || isnan(undershoot) || isnan(settleTime) || isnan(ssError) 
      continue
  end
  % code for optimizing phaseMargin
  if phaseMargin>45
      phaseMargin=phaseMargin-45;
  elseif phaseMargin<45
      phaseMargin=45-phaseMargin;
  end
  gainMargin=-1*20*log10(gainMargin);
  if clStable>1  || gainMargin>-5 || phaseMargin>15 || riseTime>3 || 100*overshoot>20 || ssError>1 
      continue
  end 
   
  
  Z(end+1,1) = clStable;
  Z(end,2) = gainMargin;   
  Z(end,3) = phaseMargin;  
  Z(end,4) = riseTime;
  Z(end,5) = overTime;
  Z(end,6) = 100*overshoot;
  Z(end,7) = 100*undershoot;
  Z(end,8) = settleTime;
  Z(end,9) = 100*ssError;
  Z(end,10)= kp;
  Z(end,11)= ki;
  warning on

end


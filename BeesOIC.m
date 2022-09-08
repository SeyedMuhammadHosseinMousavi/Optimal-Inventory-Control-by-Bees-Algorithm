%% Optimal Inventory Control (OIC) by Bees Algorithm

% There are two products or items in 5-time unit with an initial inventory 
% level of zero and a maximum capacity of 400. The system must make a balance
% between order amount and inventory amount without passing maximum capacity
% of 400 at the end of the run.
% Lower Maintenance Costs, the better.

clc;
clear;
close all;

%% Problem Definition
model=CreateModel2();                        % Create Model

model.Umax=400;

CostFunction=@(xhat) MyCost(xhat,model);	% Cost Function
VarSize=[model.K model.H];   % Size of Decision Variables Matrix
nVar=prod(VarSize);    % Number of Decision Variables

VarMin=0;         % Lower Bound of Variables
VarMax=1;         % Upper Bound of Variables

%% Bees Algorithm Parameters

MaxIt = 100;          % Maximum Number of Iterations
nScoutBee = 100;                           % Number of Scout Bees

nSelectedSite = round(0.5*nScoutBee);     % Number of Selected Sites
nEliteSite = round(0.4*nSelectedSite);    % Number of Selected Elite Sites
nSelectedSiteBee = round(0.5*nScoutBee);  % Number of Recruited Bees for Selected Sites
nEliteSiteBee = 2*nSelectedSiteBee;       % Number of Recruited Bees for Elite Sites
r = 0.1*(VarMax-VarMin);	% Neighborhood Radius
rdamp = 0.95;             % Neighborhood Radius Damp Rate

%% Initialization

% Empty Bee Structure
empty_bee.Position = [];
empty_bee.Cost = [];
empty_bee.Sol = [];

% Initialize Bees Array
bee = repmat(empty_bee, nScoutBee, 1);

% Create New Solutions
for i = 1:nScoutBee
bee(i).Position = unifrnd(VarMin, VarMax, VarSize);
[bee(i).Cost bee(i).Sol] = CostFunction(bee(i).Position);
end

% Sort
[~, SortOrder] = sort([bee.Cost]);
bee = bee(SortOrder);

% Update Best Solution Ever Found
BestSol = bee(1);

% Array to Hold Best Cost Values
BestCost = zeros(MaxIt, 1);

%% Bees Algorithm Main Loop

for it = 1:MaxIt

% Elite Sites
for i = 1:nEliteSite

bestnewbee.Cost = inf;

for j = 1:nEliteSiteBee
newbee.Position = PerformBeeDance(bee(i).Position, r);
[newbee.Cost newbee.Sol] = CostFunction(newbee.Position);
if newbee.Cost<bestnewbee.Cost
bestnewbee = newbee;
end
end

if bestnewbee.Cost<bee(i).Cost
bee(i) = bestnewbee;
end

end

% Selected Non-Elite Sites
for i = nEliteSite+1:nSelectedSite

bestnewbee.Cost = inf;

for j = 1:nSelectedSiteBee
newbee.Position = PerformBeeDance(bee(i).Position, r);
[newbee.Cost newbee.Sol] = CostFunction(newbee.Position);
if newbee.Cost<bestnewbee.Cost
bestnewbee = newbee;
end
end

if bestnewbee.Cost<bee(i).Cost
bee(i) = bestnewbee;
end
end

% Non-Selected Sites
for i = nSelectedSite+1:nScoutBee
bee(i).Position = unifrnd(VarMin, VarMax, VarSize);
[bee(i).Cost bee(i).Sol] = CostFunction(bee(i).Position);
end

% Sort
[~, SortOrder] = sort([bee.Cost]);
bee = bee(SortOrder);

% Update Best Solution Ever Found
BestSol = bee(1);

% Store Best Cost Ever Found
BestCost(it) = BestSol.Cost;

% Display Iteration Information
disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);

% Damp Neighborhood Radius
r = r*rdamp;

% Plot Solution
figure(1);
PlotSolution(BestSol.Sol,model);

end

%% ITR
figure;
plot(BestCost,'k', 'LineWidth', 2);
xlabel('ITR');
ylabel('Cost Value');
ax = gca; 
ax.FontSize = 14; 
ax.FontWeight='bold';
set(gca,'Color','c')
grid on;

%%
BestSol.Sol
disp(['Sum of Orders or Products Costs ' num2str(BestSol.Sol.SumAX)]);
disp(['Sum of Inventory or Maintenance  Costs ' num2str(BestSol.Sol.SumBI)]);
disp(['Used Capacity ' num2str(BestSol.Sol.UC)]);



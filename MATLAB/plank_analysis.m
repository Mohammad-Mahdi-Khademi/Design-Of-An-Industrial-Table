clc;
clear;
close all;

%-------------------------------------------------------------------------%

t = 0.03:0.01:0.7;
S_ut = [60, 80, 85, 100, 90, 95, 75, 70, 65];
sigma_min = 735 ./ (t.^2);
S_e = S_ut / 2;

%-------------------------------------------------------------------------%

n_values = zeros(length(sigma_min), length(S_ut));

%-------------------------------------------------------------------------%

for i = 1:length(sigma_min)
    for j = 1:length(S_ut)
        sigma = sigma_min(i);
        S_ut_value = S_ut(j);
        S_e_value = S_e(j);
        
        equation = @(n) n * 0.25 * sigma / S_e_value - (1 - n * 1.25 * sigma / S_ut_value) / (1 + n * 1.25 * sigma / S_ut_value);
        
        n_brittle = 3;
        options = optimoptions('fsolve', 'Display', 'off');
        [n_solution, fval, exitflag] = fsolve(equation, n_brittle, options);
        
        if exitflag > 0 && abs(fval) < 1e-6
            n_values(i, j) = n_solution;
        else
            n_values(i, j) = NaN;
        end
    end
end

%-------------------------------------------------------------------------%

n_valuseplusbrittle = table(n_values+3);
valid_n_values = n_values(~isnan(n_values));
[~, min_idx] = min(abs(valid_n_values - 3));
[row, col] = ind2sub(size(n_values), find(n_values == valid_n_values(min_idx)));

%-------------------------------------------------------------------------%

if ~isempty(row) && ~isempty(col)
    Table_Result_Plank = table(sigma_min(row) / 1000', S_ut(col)', n_values(row, col)', n_values(row, col)+3', t(row), ...
    'VariableNames', {'Sigma Minimum (kPa)', 'S_ut (MPa)', 'delta n', 'n', 't (m)'});
    disp(Table_Result_Plank);
else
    fprintf('No valid n values close to 3 found.\n');
end

%-------------------------------------------------------------------------%

A_table = 1.4;
B_table = 0.6;
t_table = 0.03;
ro_table = 750;
m = ro_table * A_table * B_table * t_table;
cost = m * 880000;

%-------------------------------------------------------------------------%

disp(' ');
disp('Plank:');
fprintf('m = %.2f kg\n', m);
formattedCost = sprintf('%0.0f', cost);
formattedCost = regexprep(formattedCost, '\d(?=(\d{3})+$)', '$&,');
fprintf('Cost = %s Tooman\n', formattedCost);

clc;
clear;
close all;

%-------------------------------------------------------------------------%

d = 1:0.1:51;
r_B = 20:0.1:100;

%-------------------------------------------------------------------------%

AISI_Number = [1006, 1010, 1015, 1018, 1020, 1030, 1035, 1040, 1045, 1050, 1060, 1080, 1095];

S_ut_HR = [300, 320, 340, 400, 380, 470, 500, 520, 570, 620, 680, 770, 830];
S_ut_CD = [330, 370, 390, 440, 470, 520, 550, 590, 630, 690, 1, 1, 1];

S_y_HR = [170, 280, 190, 220, 210, 260, 270, 290, 310, 340, 370, 420, 460];
S_y_CD = [280, 300, 320, 370, 390, 440, 460, 490, 530, 580, 1, 1, 1];

Table_Steel = table(AISI_Number', S_ut_HR', S_y_HR', S_ut_CD', S_y_CD', ...
    'VariableNames', {'AISI Number', 'S_ut_HR (MPa)', 'S_y_HR (MPa)', 'S_ut_CD (MPa)', 'S_y_CD (MPa)'});

%-------------------------------------------------------------------------%

K_c = 1;
K_d = 1;
K_e = 0.868;
K_f = 1;

%-------------------------------------------------------------------------%

n_HR = zeros(length(d), length(r_B), length(S_ut_HR));
n_CD = zeros(length(d), length(r_B), length(S_ut_CD));

%-------------------------------------------------------------------------%

for i = 1:length(d)
    K_a_HR = 57.7 .* (S_ut_HR.^-0.718);
    K_a_CD = 4.51 .* (S_ut_CD.^-0.265);
    K_b = 1.24 * d(i)^-0.107;
    for j = 1:length(r_B)
        if r_B(j) > d(i)
            Sigma_a_prime = (1323.15) / ((d(i) / 1000)^3) / 10^6;
            Sigma_m_prime = (29.93 * (r_B(j) / 1000)) / ((d(i) / 1000)^3) / 10^6;
            for k = 1:length(S_ut_HR)
                S_e_HR = K_a_HR(k) * K_b * K_c * K_d * K_e * K_f * (S_ut_HR(k) / 2);
                n_HR(i, j, k) = ((Sigma_a_prime / S_e_HR) + (Sigma_m_prime / S_ut_HR(k)))^-1;
            end
            for k = 1:length(S_ut_CD)
                S_e_CD = K_a_CD(k) * K_b * K_c * K_d * K_e * K_f * (S_ut_CD(k) / 2);
                n_CD(i, j, k) = ((Sigma_a_prime / S_e_CD) + (Sigma_m_prime / S_ut_CD(k)))^-1;
            end
        else
            n_HR(i, j, :) = NaN;
            n_CD(i, j, :) = NaN;
        end
    end
end

%-------------------------------------------------------------------------%

n_HR_reshaped = reshape(n_HR, [], length(S_ut_HR));
n_CD_reshaped = reshape(n_CD, [], length(S_ut_CD));

min_n_HR = min(n_HR_reshaped, [], 2);
min_n_CD = min(n_CD_reshaped, [], 2);

min_n_HR_reshaped = reshape(min_n_HR, length(d), length(r_B));
min_n_CD_reshaped = reshape(min_n_CD, length(d), length(r_B));

result_HR = table(d', min_n_HR_reshaped, 'VariableNames', {'Diameter_d', 'n_HR'});
result_CD = table(d', min_n_CD_reshaped, 'VariableNames', {'Diameter_d', 'n_CD'});

abs_diff_CD = abs(n_CD - 3);
abs_diff_HR = abs(n_HR - 3);

[min_abs_diff_CD, ind_CD] = min(abs_diff_CD(:));
[min_abs_diff_HR, ind_HR] = min(abs_diff_HR(:));

[i_CD, j_CD, k_CD] = ind2sub(size(abs_diff_CD), ind_CD);
[i_HR, j_HR, k_HR] = ind2sub(size(abs_diff_HR), ind_HR);

S_ut_CD_min = S_ut_CD(k_CD);
d_min_CD = d(i_CD);
r_B_min_CD = r_B(j_CD);
S_y_CD_min = S_y_CD(k_CD);

S_ut_HR_min = S_ut_HR(k_HR);
d_min_HR = d(i_HR);
r_B_min_HR = r_B(j_HR);
S_y_HR_min = S_y_HR(k_HR);

%-------------------------------------------------------------------------%

disp(Table_Steel);

%-------------------------------------------------------------------------%

disp("For CD:")
Table_Result_CD = table(S_ut_CD_min', S_y_CD_min', d_min_CD', r_B_min_CD', ...
    'VariableNames', {'S_ut_CD (MPa)', 'S_y_CD (MPa)', 'Diameter_d (mm)', 'r_B (mm)'});
disp(Table_Result_CD);

%-------------------------------------------------------------------------%

disp(' ');
disp("For HR:")
Table_Result_HR = table(S_ut_HR_min', S_y_HR_min', d_min_HR', r_B_min_HR', ...
    'VariableNames', {'S_ut_HR (MPa)', 'S_y_HR (MPa)', 'Diameter_d (mm)', 'r_B (mm)'});
disp(Table_Result_HR);

%-------------------------------------------------------------------------%

disp(' ');
disp('n:')
Table_Result_n = table(n_CD(i_CD, j_CD, k_CD)', n_HR(i_HR, j_HR, k_HR)', ...
    'VariableNames', {'n values for CD', 'n values for HR'});
disp(Table_Result_n);

%-------------------------------------------------------------------------%

d_shaft = 0.035;
t_shaft = 0.02;
ro_shaft = 7870;
m_shaft = ro_shaft .* (pi/4).*(d_shaft.^2) + pi.*(0.0855.^2 - d_shaft.^2).*t_shaft + pi.*(2.31.*0.0855.^2 - d_shaft.^2).*t_shaft;
cost = m_shaft / 0.15 .* 140000;

%-------------------------------------------------------------------------%

disp(' ');
disp('Shaft:');
fprintf('m = %.2f kg\n', m_shaft);
formattedCost = sprintf('%0.0f', cost);
formattedCost = regexprep(formattedCost, '\d(?=(\d{3})+$)', '$&,');
fprintf('Cost = %s Tooman\n', formattedCost);

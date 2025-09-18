clc;
clear;
close all;

%-------------------------------------------------------------------------%

F_min = 1200; 
F_max = 2400; 
L_free = 0.1; 
N_t = 27; 
spring_diameter_min = 0.01; 
spring_diameter_max = 0.03; 

Materials = ["Music Wire A228", "HD Spring A227", "Oil Tempered A229", "Valve spring A230", "Chrome-vanadium A231", "Chrome-silicon A401", "Phosphor-bronze B159", "Beryllium-copper B197", "Inconel alloy X-750"];
G = [82.7e9, 80.7e9, 77.2e9, 77.2e9, 77.2e9, 77.2e9, 41.4e9, 44.8e9, 77.2e9];

C_min = 4;
C_max = 12;

overall_best_design = struct('material', [], 'wire_diameter', [], 'mean_coil_diameter', [], 'spring_constant', [], 'num_active_coils', [], 'stress', [], 'wahl_factor', []);

for m = 1:length(Materials)
    current_material = Materials(m);
    current_G = G(m);
    
    best_design = struct('wire_diameter', [], 'mean_coil_diameter', [], 'spring_constant', [], 'num_active_coils', [], 'stress', [], 'wahl_factor', []);
    
    for D = linspace(spring_diameter_min, spring_diameter_max, 100)
        for C = linspace(C_min, C_max, 100)
            d = D / C; 

            k = (F_max - F_min) / (L_free * (N_t - 2)); % Simplified assumption

            x_max = F_max / k;
            x_min = F_min / k;
            
            Na = N_t - 2; 

            L_spring = Na * d + 2 * d;

            tau_max = (8 * F_max * D) / (pi * d^3);

            K_w = (4 * C - 1) / (4 * C - 4) + 0.615 / C;

            if L_spring <= L_free && tau_max < (current_G / 2)
                best_design.wire_diameter = d;
                best_design.mean_coil_diameter = D;
                best_design.spring_constant = k;
                best_design.num_active_coils = Na;
                best_design.stress = tau_max;
                best_design.wahl_factor = K_w;
                break;
            end
        end
    end
    
    if isempty(overall_best_design.material) || best_design.wire_diameter > overall_best_design.wire_diameter
        overall_best_design.material = current_material;
        overall_best_design.wire_diameter = best_design.wire_diameter;
        overall_best_design.mean_coil_diameter = best_design.mean_coil_diameter;
        overall_best_design.spring_constant = best_design.spring_constant;
        overall_best_design.num_active_coils = best_design.num_active_coils;
        overall_best_design.stress = best_design.stress;
        overall_best_design.wahl_factor = best_design.wahl_factor;
    end
end

disp(overall_best_design);



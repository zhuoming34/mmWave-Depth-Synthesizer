% match intensity values to corresponding points
function radar_heat = matchHeat(heatmap,N_phi,N_rho,N_theta)
    N_cell = N_phi*N_theta*N_rho;
    radar_heat = zeros(N_cell,1);
    idx_sp_coord = 1;
    for idx_rho = 1:N_rho
        for idx_phi = 1:N_phi
            for idx_theta = 1:N_theta
                radar_heat(idx_sp_coord) = heatmap(idx_rho,idx_phi,idx_theta); 
                idx_sp_coord = idx_sp_coord + 1;
            end
        end
    end
end
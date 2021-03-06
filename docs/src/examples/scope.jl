# # SCOPE Model

## load packages
using CanopyLayers
using PlotPlants
FT = Float32;
#------------------------------------------------------------------------------




# ## Initialization
# Besides the individual functions to initialize parameters for `CanopyLayers`,
#     a general function is provided to initialize all the parameters directly.
angles, can, can_opt, can_rad, in_rad, leaves, rt_con, rt_dim, soil, wls =
    initialize_rt_module(FT; nLayer=20, LAI=3);
#------------------------------------------------------------------------------




# ## Steps
## 1. Update canopy optical properties (required)
canopy_geometry!(can, angles, can_opt, rt_con);
## 2. Update scattering coefficients (required)
canopy_matrices!(leaves, can_opt);
## 3. Simulate short wave simulation (required)
short_wave!(can, can_opt, can_rad, in_rad, soil, rt_con);
## 4. Update integrated radiation fluxes (required for photosynthesis)
canopy_fluxes!(can, can_opt, can_rad, in_rad, soil, leaves, wls, rt_con);
## 5. Update SIF related spectrum (required for SIF)
SIF_fluxes!(leaves, can_opt, can_rad, can, soil, wls, rt_con, rt_dim);
## 6. Update thermo fluxes (required for leaf energy budget)
thermal_fluxes!(leaves, can_opt, can_rad, can, soil, [FT(400.0)], wls);

_fig,_axes = create_canvas("SIF example"; ncol=2);
_ax1,_ax2 = _axes;
_ax1.plot(wls.WL , can_rad.alb_obs, "k-");
_ax2.plot(wls.WLF, can_rad.SIF_obs, "k-");
set_xlabels!(_axes, ["Wave length (nm)" for i in 1:2], fontsize=12);
set_ylabels!(_axes, ["Albedo", "obs SIF (mW m⁻² nm⁻¹ sr⁻¹)"], fontsize=12);
_fig.set_tight_layout(true);
_fig
#------------------------------------------------------------------------------




# ## Change FQE
for leaf in leaves
    leaf.Cx = 0.5;
    leaf.fqe = 0.004;
    fluspect!(leaf, wls);
end
can.Ω = 0.48
canopy_geometry!(can, angles, can_opt, rt_con);
canopy_matrices!(leaves, can_opt);
short_wave!(can, can_opt, can_rad, in_rad, soil, rt_con);
canopy_fluxes!(can, can_opt, can_rad, in_rad, soil, leaves, wls, rt_con);
SIF_fluxes!(leaves, can_opt, can_rad, can, soil, wls, rt_con, rt_dim);
thermal_fluxes!(leaves, can_opt, can_rad, can, soil, [FT(400.0)], wls);

_fig,_axes = create_canvas("SIF example FQE"; ncol=2);
_ax1,_ax2 = _axes;
_ax1.plot(wls.WL , can_rad.alb_obs, "k-");
_ax2.plot(wls.WLF, can_rad.SIF_obs, "k-");
set_xlabels!(_axes, ["Wave length (nm)" for i in 1:2], fontsize=12);
set_ylabels!(_axes, ["Albedo", "obs SIF (mW m⁻² nm⁻¹ sr⁻¹)"], fontsize=12);
_fig.set_tight_layout(true);
_fig
#------------------------------------------------------------------------------

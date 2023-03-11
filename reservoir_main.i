[Mesh]
  [./file]
    type = FileMeshGenerator
    file = reservoir.msh
  [../]
  construct_side_list_from_node_list = true
[]

[GlobalParams]
  PorousFlowDictator = dictator
  multiply_by_density = true
  porepressure = porepressure
  temperature = temperature
  gravity = '-9.81 0 0'
[]

[FluidProperties]
  [water_uo]
    type = SimpleFluidProperties
    bulk_modulus = 2E9
    viscosity = 1.0e-3
    density0 = 1000.0
    thermal_expansion = 0.0
  []
[]

[UserObjects]
  [./dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'porepressure temperature'
    number_fluid_phases = 1
    number_fluid_components = 1
  [../]
[]

[Materials]
  [temperature]
    type = PorousFlowTemperature
  []
  [ppss]
    type = PorousFlow1PhaseFullySaturated
  []
  [./simple_fluid]
    type = PorousFlowSingleComponentFluid
    fp = water_uo
    phase = 0
  [../]
  [diff1]
    type = PorousFlowDiffusivityConst
    diffusion_coeff = '0'
    tortuosity = 1
  []
  [porosity]
    type = PorousFlowPorosityConst
    porosity = 0.1
  []
  [permeability_aquifer]
    type = PorousFlowPermeabilityConst
    permeability = '1.1973e-12 0 0   0 1.1973e-12 0   0 0 1.1973e-12'
  []
  [relp]
    type = PorousFlowRelativePermeabilityConst
    phase = 0
  []
  [rock_heat]
    type = PorousFlowMatrixInternalEnergy
    specific_heat_capacity = 950
    density = 2500
  []
  [./thermal_conductivity]
    type = PorousFlowThermalConductivityIdeal
    dry_thermal_conductivity = '1.986 0 0 0 1.986 0 0 0 1.986'
  [../]
  [massfrac]
    type = PorousFlowMassFraction
  []
[]

[BCs]
  # [./inj_T]
  #   type = FunctionDirichletBC
  #   variable = temperature
  #   boundary = inj_bottom
  #   function = thermalgradient
  # [../]
  [./T_sides]
  type = FunctionDirichletBC
  variable = temperature
  boundary = 'left front right back bottom'
  function = thermalgradient
 [../]
 [./pf_sides]
  type = FunctionDirichletBC
  variable = porepressure
  boundary = 'left front right back bottom'
  function = hydrostatic
 [../]
 [./outflowM]
   type = PorousFlowOutflowBC
   boundary = 'front back left right bottom top'
   variable = porepressure
   mass_fraction_component = 0
  [../]
 [./outflowT]
   type = PorousFlowOutflowBC
   boundary = 'front back left right bottom top'
   flux_type = heat
   variable = temperature
   # save_in = nodal_outflow
  [../]
[]

[ICs]
  [./hydrostatic_ic]
   type = FunctionIC
   variable = porepressure
   function = hydrostatic
  [../]
  [./T_ic]
    type = FunctionIC
    variable = temperature
    function = thermalgradient
   [../]
[]

[Functions]
  [./hydrostatic]
    type = ParsedFunction
    value = '10*1e5-1000*9.81*x'
  [../]
  [./thermalgradient]
    type = ParsedFunction
    value = '293.15-0.03*x'
  [../]
  [./massrate_inj]
    type = ParsedFunction
    value = '40'
  [../]
  [./massrate_pro]
    type = ParsedFunction
    value = '-40'
  [../]
  [./T_inj_fixed]
    type = ParsedFunction
    value = '323.15'
  [../]
[]

[Variables]
  [porepressure]
    # scaling = 1e-2
  []
  [temperature]
    scaling = 1e-7
  []
[]

[DiracKernels]
  [./inj_pp]
    type = PorousFlowPointSourceFromPostprocessor
    point = '-2000 1000 500'
    variable = porepressure
    mass_flux = massrate_inj_post
  [../]
  [./pro_pp]
    type = PorousFlowPointSourceFromPostprocessor
    point = '-2000 1000 1500'
    variable = porepressure
    mass_flux = massrate_pro_post
  [../]
  [./source_h]
   type = PorousFlowPointEnthalpySourceFromPostprocessor
   variable = temperature
   mass_flux = massrate_inj_post
   point = '-2000 1000 500'
   T_in = T_inj_fixed
   pressure = porepressure
   fp = water_uo
  [../]
  # [./sink_h]
  #  type = PorousFlowPointEnthalpySourceFromPostprocessor
  #  variable = temperature
  #  mass_flux = massrate_pro_post
  #  point = '-2000 1000 1500'
  #  T_in = T_pro_real
  #  pressure = porepressure
  #  fp = water_uo
  # [../]
[]

[Postprocessors]
  [./massrate_inj_post]
   type = FunctionValuePostprocessor
   function = massrate_inj
  [../]
  [./massrate_pro_post]
   type = FunctionValuePostprocessor
   function = massrate_pro
  [../]
  [./T_inj_fixed]
   type = FunctionValuePostprocessor
   function = T_inj_fixed
  [../]
  [./T_inj_real]
    type = PointValue
    point = '-2000 1000 500'
    variable = temperature
  [../]
  [./T_pro_real]
    type = PointValue
    point = '-2000 1000 1500'
    variable = temperature
  [../]
[]

[Kernels]
  [mass]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = porepressure
  []
  [adv]
    type = PorousFlowAdvectiveFlux
    fluid_component = 0
    variable = porepressure
  []
  [diff]
    type = PorousFlowDispersiveFlux
    fluid_component = 0
    variable = porepressure
    disp_trans = 0
    disp_long = 0
  []
  [EnergyTransient]
    type = PorousFlowEnergyTimeDerivative
    variable = temperature
  []
  [./EnergyConduciton]
    type = PorousFlowHeatConduction
    variable = temperature
  [../]
  [./EnergyAdvection]
    type = PorousFlowHeatAdvection
    variable = temperature
  [../]
[]

[Preconditioning]
  active = 'smp'
  [smp]
  type = SMP
  full = true
  petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -sub_pc_factor_shift_type -pc_asm_overlap'
  petsc_options_value = 'gmres      asm      lu           NONZERO                   2             '
[]
[]

[Executioner]
  type = Transient
  dt = 1000
  end_time = 3e+6
  l_tol = 1e-8
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-7
  l_max_its = 50
  nl_max_its = 50
  solve_type = NEWTON
 []

[Outputs]
  exodus = true
  print_linear_residuals = true
[]

[Debug]
  show_var_residual_norms = true
[]

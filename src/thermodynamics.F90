module thermodynamics_module
  !! Thermodynamics constants and abstract types.

  use kinds_module

  implicit none
  private

!------------------------------------------------------------------------
  ! Physical constants
!------------------------------------------------------------------------

  real(dp), parameter, public :: rconst     = 0.461526e3_dp     !! Gas constant
  real(dp), parameter, public :: tc_k       = 273.15_dp         !! Conversion from Celsius to Kelvin
  real(dp), parameter, public :: tcriticalk = 647.096_dp        !! Critical temperature (Kelvin)
  real(dp), parameter, public :: tcritical  = tcriticalk - tc_k !! Critical temperature (\(^\circ C\))
  real(dp), parameter, public :: dcritical  = 322.0_dp          !! Critical density (\(kg.m^{-3}\))
  real(dp), parameter, public :: pcritical  = 22.064e6_dp       !! Critical pressure (Pa)

!------------------------------------------------------------------------
  ! Thermodynamic region type
!------------------------------------------------------------------------

  type, public, abstract :: region_type
     !! Thermodynamic region type.
     contains
       private
       procedure(region_init), public, deferred :: init
       procedure(region_destroy), public, deferred :: destroy
       procedure(region_properties), public, deferred :: properties
       procedure(region_viscosity), public, deferred :: viscosity
  end type region_type

  ! Pointer to region:
  type, public :: pregion_type
     !! Pointer to thermodynamic region.
     class(region_type), pointer, public :: ptr
   contains
     procedure, public :: set => pregion_set
  end type pregion_type

!------------------------------------------------------------------------
  ! Thermodynamics type
!------------------------------------------------------------------------

  type, public, abstract :: thermodynamics_type
     !! Thermodynamics type.
     private
     integer, public :: num_regions  !! Number of thermodynamic regions
     class(region_type), allocatable, public :: water !! Pure water region
     class(region_type), allocatable, public :: steam !! Steam region
     class(region_type), allocatable, public :: supercritical !! Supercritical region
     type(pregion_type), allocatable, public :: region(:) !! Array of region pointers
   contains
     private
     procedure(thermodynamics_init_procedure), public, deferred :: init
     procedure(thermodynamics_destroy_procedure), public, deferred :: destroy
  end type thermodynamics_type

!------------------------------------------------------------------------

  abstract interface

     subroutine region_init(self)
       !! Initializes region.
       import :: region_type
       class(region_type), intent(in out) :: self
     end subroutine region_init

     subroutine region_destroy(self)
       !! Destroys region.
       import :: region_type
       class(region_type), intent(in out) :: self
     end subroutine region_destroy

     subroutine region_properties(self, param, props, err)
       !! Calculates fluid properties for region.
       import :: region_type, dp
       class(region_type), intent(in out) :: self
       real(dp), intent(in), target :: param(:)
       real(dp), intent(out) :: props(:)
       integer, intent(out) :: err
     end subroutine region_properties

     subroutine region_viscosity(self, temperature, pressure, density, viscosity)
       !! Calculates viscosity for region.
       import :: region_type, dp
       class(region_type), intent(in out) :: self
       real(dp), intent(in) :: temperature, pressure, density
       real(dp), intent(out) :: viscosity
     end subroutine region_viscosity

     subroutine thermodynamics_init_procedure(self)
       !! Initializes thermodynamics.
       import :: thermodynamics_type
       class(thermodynamics_type), intent(in out) :: self
     end subroutine thermodynamics_init_procedure

     subroutine thermodynamics_destroy_procedure(self)
       !! Destroys thermodynamics.
       import :: thermodynamics_type
       class(thermodynamics_type), intent(in out) :: self
     end subroutine thermodynamics_destroy_procedure

  end interface

!------------------------------------------------------------------------

contains

!------------------------------------------------------------------------
  ! Region pointers
!------------------------------------------------------------------------

  subroutine pregion_set(self, tgt)
    !! Sets a region pointer. This is just a workaround to give
    !! tgt the 'target' attribute, which can't always be done as part of
    !! its declaration, e.g. if it's a component of a derived type.

    class(pregion_type), intent(in out) :: self
    class(region_type), target, intent(in) :: tgt

    self%ptr => tgt

  end subroutine pregion_set

!------------------------------------------------------------------------

end module thermodynamics_module
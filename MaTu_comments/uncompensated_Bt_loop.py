import numpy as np
import matplotlib.pyplot as plt
from scipy.constants import mu_0
from scipy.special import ellipk, ellipe

# Parameters
a = 0.73  # loop radius [m]
# according to https://golem.fjfi.cvut.cz/wiki/Tokamak/ToroidalMagneticFieldCoils/Characteristics/TF%20coils%20cross%20section.png

B_t = 0.5 # T
R = 0.4 # m
N_COILS = 28
N_WINDNGS = 4 # NOT SURE WHAT THE ACTUAL VALUE IS OLD TM1 HAD 8, SO 4 COSERVATIVE OVERESTIMATE FOR CURRENT
              # https://golem.fjfi.cvut.cz/wiki/History/CASTOR/Tomakak%20TM-1-MH%20Ustavni%20zprava%20UFP%2035l77.pdf

## estimate current in B_t coils from selenoid equation
I = B_t * 2*np.pi* R / (mu_0 * N_COILS * N_WINDNGS)

print(f'B_t current {I/1e3:.2f}kA')


def Bz(rho, z, a, I):
    """
    Compute Bz from coil loop: Eq. (25) NASA report 
    https://ntrs.nasa.gov/api/citations/20140002333/downloads/20140002333.pdf
    
    Parameters
    ----------
    rho : float or array
        Radial distance from loop axis [m]
    z : float or array
        Height above loop plane [m]
    a : float
        Loop radius [m]
    I : float
        Current [A]
    """
    rho = np.asarray(rho, dtype=float)
    z = np.asarray(z, dtype=float)
    
    alpha2 = (a - rho)**2 + z**2
    beta2 = (a + rho)**2 + z**2
    beta = np.sqrt(beta2)
    
    m = 1 - alpha2 / beta2
    K = ellipk(m)
    E = ellipe(m)
    
    C = mu_0 * I / np.pi
    Bz = (C / (2 * alpha2 * beta)) * ((a**2 - rho**2 - z**2) * E + alpha2 * K)
    return Bz

rhos = np.linspace(0, a*0.99, 100)
zs = np.zeros_like(rhos)
Bz_vals = Bz(rhos,zs, a, I)

Bz_vals_Plasma_Center = Bz_vals[np.argmin(np.abs(rhos-0.4))]

# Plot
plt.figure(figsize=(7,5))
plt.plot(rhos, Bz_vals*1e3, label=r"$B_z$ in plane ($z=0$)")

plt.xlabel(r"Radial position $\rho$ [m]")
plt.ylabel(r"$B_z$ [mT]")
plt.title(f"Magnetic field along loop\nRadius a={a} m, Current I={I/1e3:.0f}kA")
plt.grid(True)
plt.ylim(top = 5e3*Bz_vals_Plasma_Center)
plt.axvline(0.4, label = f'vertical field {Bz_vals_Plasma_Center*1e3:.0f}mT', color = 'k', ls = ':')
plt.legend()
plt.savefig('MgFieldFromUcompensatedBRloop.png')
plt.show()



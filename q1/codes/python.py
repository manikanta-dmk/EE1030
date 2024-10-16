import sys
import ctypes
import numpy as np
import matplotlib.pyplot as plt

# Add path to the CoordGeo directory
sys.path.insert(0, './CoordGeo')

# Load the shared library
lib = ctypes.CDLL('./code.so')

# Define function signatures from the library
lib.createMat.restype = ctypes.POINTER(ctypes.POINTER(ctypes.c_double))
lib.createMat.argtypes = [ctypes.c_int, ctypes.c_int]

lib.externalDivision.restype = ctypes.POINTER(ctypes.POINTER(ctypes.c_double))
lib.externalDivision.argtypes = [ctypes.POINTER(ctypes.POINTER(ctypes.c_double)),
                                 ctypes.POINTER(ctypes.POINTER(ctypes.c_double)),
                                 ctypes.c_double,
                                 ctypes.c_double]

lib.midpoint.restype = ctypes.POINTER(ctypes.POINTER(ctypes.c_double))
lib.midpoint.argtypes = [ctypes.POINTER(ctypes.POINTER(ctypes.c_double)),
                         ctypes.POINTER(ctypes.POINTER(ctypes.c_double))]

lib.freeMat.argtypes = [ctypes.POINTER(ctypes.POINTER(ctypes.c_double)), ctypes.c_int]

# Create matrices for P and Q
P = lib.createMat(2, 1)
Q = lib.createMat(2, 1)

# Assign values to position vectors P and Q
P[0][0] = ctypes.c_double(2.0)  # 2a
P[1][0] = ctypes.c_double(1.0)  # b
Q[0][0] = ctypes.c_double(1.0)  # a
Q[1][0] = ctypes.c_double(-3.0) # -3b

# Compute R and M
R = lib.externalDivision(P, Q, ctypes.c_double(1), ctypes.c_double(2))
M = lib.midpoint(R, Q)

# Extract values for plotting
R_x = R[0][0]
R_y = R[1][0]
M_x = M[0][0]
M_y = M[1][0]
P_x = P[0][0]
P_y = P[1][0]
Q_x = Q[0][0]
Q_y = Q[1][0]

# Plotting
plt.figure()
plt.plot([P_x, Q_x], [P_y, Q_y], 'bo-', label='Line PQ')  # Line PQ
plt.plot([R_x, Q_x], [R_y, Q_y], 'ro--', label='Line RQ')  # Line RQ
plt.plot(M_x, M_y, 'gs', label='Midpoint M')  # Midpoint M
plt.plot(P_x, P_y, 'ms', label='Point P')  # Point P
plt.plot(R_x, R_y, 'cs', label='Point R')  # Point R

# Labeling the coordinates
plt.scatter([P_x, Q_x, R_x, M_x], [P_y, Q_y, R_y, M_y])
plt.annotate('P', (P_x, P_y), textcoords="offset points", xytext=(-10,-5), ha='center')
plt.annotate('Q', (Q_x, Q_y), textcoords="offset points", xytext=(-10,-5), ha='center')
plt.annotate('R', (R_x, R_y), textcoords="offset points", xytext=(-10,-5), ha='center')
plt.annotate('M', (M_x, M_y), textcoords="offset points", xytext=(-10,-5), ha='center')

# Formatting the plot
plt.axhline(0, color='black', lw=0.5, ls='--')
plt.axvline(0, color='black', lw=0.5, ls='--')
plt.grid()
plt.legend(loc='best')
plt.axis('equal')
plt.title('Graph of Position Vectors and Midpoint')
plt.xlabel('X-axis')
plt.ylabel('Y-axis')

# Show the plot
plt.savefig('graph.png')
plt.show()

# Free allocated memory
lib.freeMat(P, 2)
lib.freeMat(Q, 2)
lib.freeMat(R, 2)
lib.freeMat(M, 2)


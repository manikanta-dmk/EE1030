#include <stdio.h>
#include <complex.h>
#include <math.h>

#define TOLERANCE 1e-6
#define MAX_ITER 1000
#define MAX_SIZE 100 

// Function prototypes
void hessenbergReduction(double complex matrix[MAX_SIZE][MAX_SIZE], int size);
void qrDecomposition(double complex matrix[MAX_SIZE][MAX_SIZE], int size, double complex Q[MAX_SIZE][MAX_SIZE], double complex R[MAX_SIZE][MAX_SIZE]);
void matrixMultiply(double complex A[MAX_SIZE][MAX_SIZE], double complex B[MAX_SIZE][MAX_SIZE], double complex result[MAX_SIZE][MAX_SIZE], int size);
void solve2x2Complex(double complex a, double complex b, double complex c, double complex d, double complex *eig1, double complex *eig2);
void printMatrix(double complex matrix[MAX_SIZE][MAX_SIZE], int size);

int main() {
    int size;
      printf("Enter the size of the square matrix (N x N):\n ");
    scanf("%d", &size);
   // Declare matrices
    double complex A[MAX_SIZE][MAX_SIZE];
    double complex Q[MAX_SIZE][MAX_SIZE];
    double complex R[MAX_SIZE][MAX_SIZE];
    double complex Ak[MAX_SIZE][MAX_SIZE];
    double complex temp[MAX_SIZE][MAX_SIZE];
 // Input the matrix
    printf("Enter the real and imaginary parts of the matrix elements row by row:\n");
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            double real, imag;
            printf("Element [%d][%d] (real, imag): ", i + 1, j + 1);
            scanf("%lf %lf", &real, &imag);
            A[i][j] = real + imag * I;
            Ak[i][j] = A[i][j]; // Copy for processing
        } }
    // Step 1: Transform to Hessenberg form (not printed)
    hessenbergReduction(Ak, size);
    // Step 2: Perform QR Iterations
    int iterations = 0;
    while (iterations < MAX_ITER) {
        // QR decomposition
        qrDecomposition(Ak, size, Q, R);
       // Compute Ak+1 = R * Q
        matrixMultiply(R, Q, temp, size);
       // Update Ak
        for (int i = 0; i < size; i++) {
            for (int j = 0; j < size; j++) {
                Ak[i][j] = temp[i][j];
            }
        }
      // Check convergence
        int converged = 1;
        for (int i = 0; i < size - 1; i++) {
            if (cabs(Ak[i + 1][i]) > TOLERANCE) {
                converged = 0;
                break;
            }
        }
        if (converged) break;
         iterations++;
    }
   if (iterations >= MAX_ITER) {
        printf("\nWARNING: Maximum iterations reached. Results may not have converged.\n");
    }
      // Step 3: Extract Eigenvalues
    printf("\nEigenvalues:\n");
    for (int i = 0; i < size; i++) {
        if (i < size - 1 && cabs(Ak[i + 1][i]) > TOLERANCE) {
            // Handle 2x2 block for complex eigenvalues
            double complex eig1, eig2;
            solve2x2Complex(Ak[i][i], Ak[i][i + 1], Ak[i + 1][i], Ak[i + 1][i + 1], &eig1, &eig2);
            printf("Eigenvalue %d: %.6f + %.6fi\n", i + 1, creal(eig1), cimag(eig1));
            printf("Eigenvalue %d: %.6f + %.6fi\n", i + 2, creal(eig2), cimag(eig2));
            i++; // Skip next row
        } else {
            // Real eigenvalue
            printf("Eigenvalue %d: %.6f + %.6fi\n", i + 1, creal(Ak[i][i]), cimag(Ak[i][i]));
        }
    }
 return 0;
}
// Hessenberg Reduction
void hessenbergReduction(double complex matrix[MAX_SIZE][MAX_SIZE], int size) {
    for (int k = 0; k < size - 2; k++) {
        for (int i = k + 2; i < size; i++) {
            double complex x = matrix[k + 1][k];
            double complex y = matrix[i][k];
            double complex r = csqrt(x * conj(x) + y * conj(y));
            double complex c = x / r;
            double complex s = -y / r;

            for (int j = k; j < size; j++) {
                double complex temp1 = c * matrix[k + 1][j] - s * matrix[i][j];
                double complex temp2 = s * matrix[k + 1][j] + c * matrix[i][j];
                matrix[k + 1][j] = temp1;
                matrix[i][j] = temp2;
            }

            for (int j = 0; j < size; j++) {
                double complex temp1 = c * matrix[j][k + 1] - s * matrix[j][i];
                double complex temp2 = s * matrix[j][k + 1] + c * matrix[j][i];
                matrix[j][k + 1] = temp1;
                matrix[j][i] = temp2;
            }
        } }
    }

// QR Decomposition
void qrDecomposition(double complex matrix[MAX_SIZE][MAX_SIZE], int size, double complex Q[MAX_SIZE][MAX_SIZE], double complex R[MAX_SIZE][MAX_SIZE]) {
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            R[i][j] = 0.0 + 0.0 * I;
        }
    }

    for (int i = 0; i < size; i++) {
        R[i][i] = 0.0 + 0.0 * I;
        for (int k = 0; k < size; k++) {
            R[i][i] += conj(matrix[k][i]) * matrix[k][i];
        }
        R[i][i] = csqrt(R[i][i]);

        for (int k = 0; k < size; k++) {
            Q[k][i] = matrix[k][i] / R[i][i];
        }

        for (int j = i + 1; j < size; j++) {
            R[i][j] = 0.0 + 0.0 * I;
            for (int k = 0; k < size; k++) {
                R[i][j] += conj(Q[k][i]) * matrix[k][j];
            }
        }

        for (int j = i + 1; j < size; j++) {
            for (int k = 0; k < size; k++) {
                matrix[k][j] -= Q[k][i] * R[i][j];
            }
        }
    } }
// Matrix Multiplication
void matrixMultiply(double complex A[MAX_SIZE][MAX_SIZE], double complex B[MAX_SIZE][MAX_SIZE], double complex result[MAX_SIZE][MAX_SIZE], int size) {
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            result[i][j] = 0.0 + 0.0 * I;
            for (int k = 0; k < size; k++) {
                result[i][j] += A[i][k] * B[k][j];
            }
        } }
    }

// Solve 2x2 Complex Eigenvalues
void solve2x2Complex(double complex a, double complex b, double complex c, double complex d, double complex *eig1, double complex *eig2) {
    double complex trace = a + d;
    double complex det = a * d - b * c;
    double complex discriminant = csqrt(trace * trace / 4.0 - det);

    *eig1 = trace / 2.0 + discriminant;
    *eig2 = trace / 2.0 - discriminant;
}

#include <stdio.h>
#include <stdlib.h>

// Function declarations
double **createMat(int m, int n);
double **externalDivision(double **P, double **Q, double m, double n);
double **midpoint(double **R, double **Q);
void printMat(double **p, int m, int n);
void freeMat(double **mat, int m);

int main() {
    // Define vectors P and Q
    double **P = createMat(2, 1);
    double **Q = createMat(2, 1);

    P[0][0] = 2; // 2a
    P[1][0] = 1; // b
    Q[0][0] = 1; // a
    Q[1][0] = -3; // -3b

    // Calculate R
    double **R = externalDivision(P, Q, 1, 2);

    // Calculate midpoint M of RQ
    double **M = midpoint(R, Q);

    // Print results
    printf("Position vector R: \n");
    printMat(R, 2, 1);
    
    printf("Midpoint M: \n");
    printMat(M, 2, 1);
    
    printf("P: \n");
    printMat(P, 2, 1);

    // Check if M is equal to P
    if (M[0][0] == P[0][0] && M[1][0] == P[1][0]) {
        printf("P is the midpoint of RQ: True\n");
    } else {
        printf("P is the midpoint of RQ: False\n");
    }

    // Free allocated memory
    freeMat(P, 2);
    freeMat(Q, 2);
    freeMat(R, 2);
    freeMat(M, 2);

    return 0;
}

// Create matrix
double **createMat(int m, int n) {
    double **a = (double **)malloc(m * sizeof(double *));
    for (int i = 0; i < m; i++)
        a[i] = (double *)malloc(n * sizeof(double));
    return a;
}

// External division of line segment
double **externalDivision(double **P, double **Q, double m, double n) {
    double **R = createMat(2, 1);
    R[0][0] = (n * P[0][0] - m * Q[0][0]) / (n - m);
    R[1][0] = (n * P[1][0] - m * Q[1][0]) / (n - m);
    return R;
}

// Midpoint calculation
double **midpoint(double **R, double **Q) {
    double **M = createMat(2, 1);
    M[0][0] = (R[0][0] + Q[0][0]) / 2;
    M[1][0] = (R[1][0] + Q[1][0]) / 2;
    return M;
}

// Print matrix
void printMat(double **p, int m, int n) {
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++)
            printf("%lf ", p[i][j]);
        printf("\n");
    }
}

// Free allocated memory
void freeMat(double **mat, int m) {
    for (int i = 0; i < m; i++)
        free(mat[i]);
    free(mat);
}


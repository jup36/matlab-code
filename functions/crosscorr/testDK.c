#include "mex.h"
#include <time.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int i = 0;
    double *C;
    srand(time(NULL));
    
    
    plhs[0] = mxCreateDoubleMatrix(10, 10, mxREAL);
    C = mxGetPr(plhs[0]);
    
    
    
    for (i=0; i < 10; i++) {
        C[i, 2] = 5*(((double)rand())/32767*2 - 1) - 10;
    }
}

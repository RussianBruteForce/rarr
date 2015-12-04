module solve;

import rarr.matrix;
import rarr.vector;
import std.math : abs;
import std.algorithm.mutation;

/// solve: class for solving matrix
class solve
{
    static auto gaussian(T)(const ref matrix!T M, const ref vector!T b)
    {
        T[][] A = rarr.copy(M).data;
        //A.length = b.size;
        //foreach(i; 0 .. b.size)
        //{
        //    A[i].length = b.size;
        //    foreach(j; 0 .. b.size)
       //    {
        //        A[i][j] = M.data[i][j];
        //    }
        //}
        T[] x = rarr.copy(b).data;

        foreach(k; 0 .. A.length)
        {
            size_t imax = find_max(A, k);
            assert(A[imax][k] != 0);
            swap(A[k], A[imax]);
            swap(x[k], x[imax]);
            if (k+1 == A.length)
                break;
            for(auto i = k+1; i < A.length; i++)
            {
                double c = A[i][k]/A[k][k];

                A[i][k] = 0;
                for(auto j = k+1; j < A.length; j++)
                {
                    //write(j, "|", k);
                    if (k >= A.length || j>= A.length || i >= A.length)
                        break;
                    A[i][j] -= c*A[k][j];
                }
                x[i] = c*x[k];
            }
        }

        return new vector!T(x);
    }

private:
    static find_max(T)(const ref T[][] A, size_t k)
    {
        size_t imax = k;
        T max_pivot = abs(A[k][k]);
        foreach(i; k+1 .. A.length)
        {
            T a = abs(A[i][k]);
            if (a > max_pivot)
            {
                max_pivot = a;
                imax = i;
            }
        }
        return imax;
    }
}

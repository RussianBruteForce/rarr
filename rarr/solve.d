module solve;

import rarr.matrix;
import rarr.vector;
import std.conv;
import std.math;
import std.algorithm;
import std.range;
//import std.typecons;
import std.numeric;

debug = s;
debug(s) import std.stdio;

/// solve: class for solving matrix
class solve
{
    /// classic Gauss method
    static auto gaussian(T)(const ref matrix!T _A, const ref vector!T b)
    in
    {
        assert(_A.size == b.size);
    }
    body
    {
        immutable n = _A.size;
        enum eps = 1e-6;

        auto A = _A.cdata.zip(b.cdata).map!(c => [] ~ c[0] ~ c[1]).array;
        debug(s) writeln("A ", A);
        debug(s) writeln(n, " ", A.length);

        // Wikipedia algorithm from Gaussian elimination page,
        // produces row-eschelon form.
        foreach (k; 0 .. A.length)
        {
            // Find pivot for column k and swap.
            A[k .. n].minPos!((x, y) => x[k] > y[k]).front.swap(A[k]);

            assert(A[k][k].abs > eps);

            // Do for all rows below pivot.
            foreach (i; k + 1 .. n)
            {
                // Do for all remaining elements in current row.
                A[i][k+1 .. n+1] -= A[k][k+1 .. n+1] * (A[i][k] / A[k][k]);

                A[i][k] = 0; // Fill lower triangular matrix with zeros.
            }
        }

        auto x = new T[n];
        foreach_reverse (immutable i; 0 .. n)
        {
            x[i] = (A[i][n] - A[i][i+1 .. n].dotProduct(x[i+1 .. n])) / A[i][i];
        }
        return new vector!T(x);
    }

    /// Seidel method
    static auto seidel(T)(auto const ref matrix!T A, const ref vector!T b, const T eps)
    in
    {
        assert(A.size == b.size);
    }
    body
    {
        immutable n = b.size;
        T[] x; x.length = n;
        x.each!((ref a) => a = 0);

        while (true)
        {
            auto p = x.dup;
            foreach(i; 0 .. n)
            {
                T buf = 0;
                foreach(j; 0 .. i)
                {
                    buf += A.cdata[i][j] * x[j];
                }
                foreach(j; i+1 .. n)
                {
                    buf += A.cdata[i][j] * p[j];
                }
                x[i] = (b[i] - buf) / A.cdata[i][i];
            }
            T ceps = 0;
            foreach(i; 0 .. n) // spherical norm
            {
                ceps += (x[i]-p[i])*(x[i]-p[i]);
            }
            if (ceps <= eps) break;
        }
        return new vector!T(x);
    }

    static auto residual(T)(auto const ref matrix!T A, const ref vector!T x, const ref vector!T b)
    in
    {
        assert((x.size + b.size)/2 == A.size);
    }
    body
    {
        auto _b_ = A*x;
        auto d_b = _b_ - b;
        return d_b.norm(d_b.norm_t.sphere);
    }
}

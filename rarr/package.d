module rarr;

public import rarr.vector;
public import rarr.matrix;
public import rarr.solve;


/// copy matrix
auto copy(T)(const ref matrix!T m)
{
    T[][] ret;
    ret.length = m.size;
    foreach(size_t i; 0 .. m.size)
    {
        ret[i].length = m.size;
        foreach(size_t j; 0 .. m.size)
        {
            ret[i][j] = m.cdata[i][j];
        }
    }
    return new matrix!T(ret);
}

/// copy vector
auto copy(T)(const ref vector!T v)
{
    T[] ret;
    ret.length = v.size;
    foreach(size_t i; 0 .. v.size)
    {
            ret[i] = v.cdata[i];
    }
    return new vector!T(ret);
}

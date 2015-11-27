module matrix;

import std.algorithm.iteration : each;
import std.file;
import std.string;
import std.conv;

import rarr.vector;

debug = m;

debug(m) import std.stdio;

class matrix(T)
{
    @property size_t size() { return m_data.length; }
    @property T[][] data() {return m_data;};

    alias type = T;

    /// norm types
    static enum norm_t {
        /// 1
        octo,
        /// inf
        cubic
    };

    this (T[][] data)
    {
        foreach (i; 0 .. data.length)
            assert(data.length == data[i].length);
        this.m_data = data;
        debug(m) writeln("constr ", this.m_data);
    }

    static auto opCall(M)(M[][] data) { return new matrix!M(data); }

    /// construct new matrix from file filename
    static auto opCall(string filename)
    {
        assert(exists(filename));
        T[][] new_data;
        string[] lines = splitLines(readText(filename));
        lines.each!((ref string a) => new_data ~= vector!T.array_from_line(a));

        return new matrix!T(new_data);
    }

    auto t()
    {
        T[][] new_data;
        new_data.length = this.size;
        foreach(i; 0 .. this.size)
        {
            new_data[i].length = this.size;
            foreach(j; 0 .. this.size)
            {
                new_data[i][j] = this.m_data[j][i];
            }
        }
        return new matrix!T(new_data);
    }

    auto opCast(type)() if (typeid(type) == typeid(T[][])) { return this.m_data; }

    /// returns norm of type type
    auto norm(norm_t type)
    {
        switch(type)
        {
        case norm_t.octo:
            return norm_octo();
            break;
        case norm_t.cubic:
            return norm_cubic();
            break;
        default:
            assert(0);
        }
    }

    auto opIndex(size_t row, size_t col) { return m_data[row][col]; }

    auto opIndexAssign(T value, size_t row, size_t col) { return m_data[row][col] = value; }

//    auto addRow(T[] row)
//    {
//        this.m_data ~= row;
//        debug(m) writeln("add row ", this.m_data);
//        return this;
//    }

    auto opBinary(string op)(T rhs) //if(op == "*" || op == "+")
    {
        T[][] new_data;
        new_data.length = this.size;
        foreach(i; 0 .. this.size)
        {
            new_data[i].length = this.size;
            foreach(j; 0 .. this.size)
            {
                mixin("new_data[i][j] = this.m_data[i][j]" ~ op ~ "rhs;");
            }
        }
        debug(m) writeln("matrix " ~op~ " on ", rhs);
        return new matrix!T(new_data);
    }

    auto opBinary(string op)(matrix rhs) if (op == "+" || op == "-")
    {
        assert(this.size == rhs.size);
        T[][] new_data;
        new_data.length = this.size;
        foreach(i; 0 .. this.size)
        {
            new_data[i].length = this.size;
            foreach(j; 0 .. this.size)
            {
                mixin("new_data[i][j] = this.m_data[i][j]" ~op~ "rhs.data[i][j];");
            }
        }
        debug(m) writeln("matrix " ~op~ " matrix");
        return new matrix!T(new_data);
    }

    auto opBinary(string op)(matrix rhs) if (op == "*")
    {
        assert(this.size == rhs.size);
        T[][] new_data;
        new_data.length = this.size;
        foreach(i; 0 .. this.size)
        {
            new_data[i].length = this.size;
            foreach(j; 0 .. this.size)
            {
                foreach(k; 0 .. this.size)
                {
                    new_data[i][j] += this.m_data[i][k] * rhs.data[k][j];
                }
            }
        }
        debug(m) writeln("matrix " ~op~ " matrix");
        return new matrix!T(new_data);
    }

    auto opBinary(string op)(vector!T rhs) if (op == "*")
    {
        assert(this.size == rhs.size);
        T[] new_data;
        new_data.length = this.size;
        foreach(i; 0 .. this.size)
        {
            foreach(j; 0 .. this.size)
            {
                new_data[i] += rhs.data[j] * this.m_data[i][j];
                writeln(new_data[i]);
            }
        }
        debug(m) writeln("matrix " ~op~ " vector");
        return new vector!T(new_data);
    }

    auto opOpAssign(string op)(T rhs) //if(op == "*" || op == "+" || op == "/")
    {
        foreach(i; 0 .. this.size)
        {
            foreach(j; 0 .. this.m_data[i].length)
            {
                mixin("this.m_data[i][j]" ~ op ~ "=rhs;");
            }
        }
        debug(m) writeln("matrix " ~op~ "= on ", rhs);
        return this;
    }

    auto opOpAssign(string op)(matrix rhs) if (op == "+" || op == "-")
    {
        assert(this.size == rhs.size);
        foreach(i; 0 .. this.size)
        {
            foreach(j; 0 .. this.size)
            {
                 mixin("this.m_data[i][j]" ~op~ "= rhs.data[i][j];");
            }
        }
        debug(m) writeln("matrix " ~op~ "= matrix");
        return this;
    }

    auto opOpAssign(string op)(matrix rhs) if (op == "*")
    {
        assert(this.size == rhs.size);
        debug(m) writeln("matrix " ~op~ "= matrix");
        return this.m_data = (this * rhs).data;
    }

private:
    T[][] m_data;

    //static p(M)(M m) { return cast(T[][])m; }

    auto v_abs(ref T[] arr)
    {
        T tmp = 0;
        arr.each!(a => tmp += abs(a));
        return tmp;
    }

    auto norm_octo()
    {
        T tmp = 0;
        foreach(i; 0 .. this.size)
        {
            T[] buf;
            buf.length = this.size;
            foreach(j; 0 .. this.size)
            {
                buf[j] = this.m_data[j][i];
            }
            tmp = v_abs(buf)>tmp?v_abs(buf):tmp;
        }
        return tmp;
    }

    auto norm_cubic()
    {
        T tmp = v_abs(this.m_data[0]);
        this.m_data.each!((ref a) => (v_abs(a)>tmp)?(tmp=v_abs(a)):tmp);
        return tmp;
    }
}

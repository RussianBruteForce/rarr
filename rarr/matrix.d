module matrix;

import std.algorithm.iteration : each;
import std.file;
import std.string;
import std.conv;
import std.random;
import std.stdio;

import rarr.vector;

//debug = m;


/++
    matrix: class for math square matrix representation
+/

class matrix(T)
{
    ///getter and setter for length of inner arrays
    @property size_t size() const { return m_data.length; }
    /// ditto
    @property size_t size(const size_t size) {
        this.m_data.length = size;
        this.m_data.each!((ref a) => a.length = size);
        return this.m_data.length;
    }
    /// pointer to inner array
    @property T[][] data() {return this.m_data;};
    /// dito
    @property auto cdata() const {return to!(const T[][])(this.m_data);};

    alias type = T;

    /// norm types
    static enum norm_t {
        /// 1
        octo,
        /// inf
        cubic
    };

    /// construct matrix from data
    this (T[][] data)
    {
        foreach (i; 0 .. data.length)
            assert(data.length == data[i].length);
        this.m_data = data;
        debug(m) writeln("constr ", this.m_data);
    }

    /// construct new matrix through calling class as a function
    static auto opCall(M)(M[][] data) { return new matrix!M(data); }

    /**
        construct new matrix from file
        Param:
            filename =  file name
            separator = number separator
    */
    static auto opCall(string filename, char separator = ';')
    {
        assert(exists(filename));
        T[][] new_data;
        string[] lines = splitLines(readText(filename));
        lines.each!((ref string a) => new_data ~= vector!T.array_from_line(a, separator));

        return new matrix!T(new_data);
    }

    /**
        save matrix to file
        Param:
            filename =  file name
            separator = number separator
        TODO:
            make this shit const
    */
    auto save(string filename, char separator = ';')
    {
        auto f = File(filename, "w");
        auto writer(T)(ref T[] arr)
        {
            f.writeln(vector!T.line_from_array(arr, separator));
        };
        this.m_data.each!((ref a) => writer(a));
        // f exits scope, reference count falls to zero,
        // underlying $(D FILE*) is closed.
    }

    /// construct new matrix of size filled with 0
    static auto opCall(size_t size) {
        auto v = new matrix!T([[0]]);
        v.size = size;
        return v;
    }

    /**
        fill matrix with random data
        Params:
            _a =     min
            _b =     max
    */
    auto randomize(T _a, T _b)
    {
        assert(_a < _b);
        auto gen = Random(unpredictableSeed);
        auto rv(ref T[] x) { x.each!((ref a) => a = uniform(_a, _b, gen)); };
        this.m_data.each!((ref a) => rv(a));
        return this;
    }

    /// returns $(I NEW) transposed matrix
    auto t() const
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

    /// cast to T[][] returns inner array
    auto opCast(type)() if (typeid(type) == typeid(T[][])) { return this.m_data; }

    /// returns norm of type type
    auto norm(norm_t type) const
    {
        final switch(type)
        {
        case norm_t.octo:
            return norm_octo();
            break;
        case norm_t.cubic:
            return norm_cubic();
            break;
        }
    }

    /**
        getter and setter through index
    */
    auto opIndex(const size_t row, const size_t col) const { return m_data[row][col]; }
    /// ditto
    auto opIndexAssign(T value, const size_t row, const size_t col) { return m_data[row][col] = value; }

//    auto addRow(T[] row)
//    {
//        this.m_data ~= row;
//        debug(m) writeln("add row ", this.m_data);
//        return this;
//    }

    /// apply op on each matrix element
    auto opBinary(string op)(T rhs) const //if(op == "*" || op == "+")
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

    /// add and subs ops between matrix of same size
    auto opBinary(string op)(matrix rhs) const if (op == "+" || op == "-")
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

    /// multiplication of same size matrix
    auto opBinary(string op)(matrix rhs) const if (op == "*")
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

    /// multiplication on vector of same size
    auto opBinary(string op)(const vector!T rhs) const if (op == "*")
    {
        assert(this.size == rhs.size);
        T[] new_data;
        new_data.length = this.size;
        foreach(i; 0 .. this.size)
        {
            new_data[i] = 0;
            foreach(j; 0 .. this.size)
            {
                new_data[i] += rhs.cdata[j] * this.m_data[i][j];
                debug(m) writeln(new_data[i]);
            }
        }
        debug(m) writeln("matrix " ~op~ " vector");
        return new vector!T(new_data);
    }

    /// assign op aplly on each element
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

    /// ditto
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


    /// assign multiplication
    auto opOpAssign(string op)(matrix rhs) if (op == "*")
    {
        assert(this.size == rhs.size);
        debug(m) writeln("matrix " ~op~ "= matrix");
        return this.m_data = (this * rhs).data;
    }

private:
    T[][] m_data;

    //static p(M)(M m) { return cast(T[][])m; }

    static auto v_abs(const ref T[] arr)
    {
        T tmp = 0;
        arr.each!(a => tmp += abs(a));
        return tmp;
    }

    auto norm_octo() const
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

    auto norm_cubic() const
    {
        T tmp = v_abs(this.m_data[0]);
        this.m_data.each!((ref a) => (v_abs(a)>tmp)?(tmp=v_abs(a)):tmp);
        return tmp;
    }
}

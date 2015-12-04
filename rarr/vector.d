module vector;

import std.math : sqrt, abs, round;
import std.algorithm.iteration : each;
import std.file;
import std.string;
import std.conv;
import std.random;

debug = v;
debug(v) import std.stdio;

/++
    vector: class for math vector representation
+/

class vector(T)
{
    ///getter and setter for length of inner array
    @property size_t size() const { return this.m_data.length; }
    /// ditto
    @property size_t size(size_t l) { return this.m_data.length = l; }
    /// pointer to inner array
    @property T[] data() { return this.m_data; };
    /// dito
    @property auto cdata() const { return to!(const T[])(this.m_data); };

    /// stored data type
    alias type = T;

    /// norm types
    static enum norm_t {
        /// 2
        sphere,
        /// 1
        octo,
        /// inf
        cubic
    };

    /// construct vector with the data
    this (T[] data)
    {
        this.m_data = data;
        debug(v) writeln("constr ", this.m_data);
    }

    /// construct new vector through calling class as a function
    static auto opCall(T[] data) { return new vector!T(data); }

    /**
        construct new vector from file
        Param:
            filename =  file name
            separator = number separator
    */
    static auto opCall(string filename, char separator = ';')
    {
        assert(exists(filename));
        string[] lines = splitLines(readText(filename));
        debug(v) writeln(lines);
        assert(lines.length == 1);
        return new vector!T(array_from_line(lines[0], separator));
    }

    /**
        save vector to file
        Param:
            filename =  file name
            separator = number separator
        TODO:
            make this shit const
    */
    auto save(string filename, char separator = ';')
    {
        auto f = File(filename, "w");
        f.writeln(line_from_array(this.m_data, separator));
        // f exits scope, reference count falls to zero,
        // underlying $(D FILE*) is closed.
    }

    /// construct new vector of size filled with 0
    static auto opCall(size_t size) {
        auto v = new vector!T([0]);
        v.size = size;
        return v;
    }

    /**
        fill vector with random data
        Params:
            _a =     min
            _b =     max
    */
    auto randomize(T _a, T _b)
    {
        //debug(v) writefln("min %d max %d", T.min, T.max);
        assert(_a < _b);
        auto gen = Random(unpredictableSeed);
        this.m_data.each!((ref a) => a = uniform(_a, _b, gen));
        return this;
    }

    static auto array_from_line(const ref string line, char separator)
    {
        T[] new_data;
        string buf;
        debug(v) writeln("line: ",line);
        foreach(i; 0.. line.length)
        {
            if (line[i] == separator)
            {
                    new_data ~= to!T(buf);
                    buf.length = 0;
            } else
            {
                    buf ~= line[i];
            }
        }
        new_data ~= to!T(buf);
        debug(v) writeln("parsed array ", new_data);
        return new_data;
    }

    static auto line_from_array(const ref T[] array, char separator)
    {
        string ret;
        size_t i = 0;
        auto app = (const T x) {
            ret ~= text(x);
            if (++i != array.length) ret ~= separator;
        };
        array.each!(a => app(a));
        return ret;
    }

    /// cast to array returns inner array
    auto opCast(type)() if (typeid(type) == typeid(T[])) { return this.m_data; }

    /// returns norm of type type
    auto norm(norm_t type) const
    {
        final switch(type)
        {
        case norm_t.sphere:
            return norm_sphere();
            break;
        case norm_t.octo:
            return norm_octo();
            break;
        case norm_t.cubic:
            return norm_cubic();
            break;
        }
    }

    /// getter and setter through the index i
    auto opIndex(size_t i) const { return m_data[i]; }
    /// ditto
    auto opIndexAssign(T value, size_t i) { return m_data[i] = value; }

    //auto add(T value) { return this.m_data ~= value; }

    //auto add(T[] data) { return this.m_data ~= data; }

    /// apply op on each element of inner array
    auto opBinary(string op)(T rhs) const //if (op == "*" || op == "+")
    {
        T[] new_data;
        foreach(i; 0 .. new_data.length)
        {
            mixin("new_data[i]" ~ op ~ "=rhs;");
        }
        debug(v) writeln("bin ", op, " on ", this.m_data);
        return new vector!T(new_data);
    }

    /// multiplication of arrays with same size
    auto opBinary(string op)(vector rhs) const if (op == "*")
    {
        assert(this.size == rhs.size);
        T ret = 0;
        foreach(i; 0 .. this.size)
        {
            ret += this.m_data[i] * p(rhs)[i];
        }
        return ret;
    }

    /// addition and substraction of vectors with same size
    auto opBinary(string op)(vector rhs) const if (op == "+" || op == "-")
    {
        assert(this.size == rhs.size);
        T[] new_data;
        new_data.length = this.size;
        foreach(i; 0 .. this.size)
        {
            mixin("new_data[i] = this.m_data[i]" ~op~ "rhs.data[i];");
        }
        return new vector!T(new_data);
    }

    /// assign operations op sended to inner array
    auto opOpAssign(string op)(T rhs) { mixin("return this.m_data" ~op~ "=rhs;"); }
    auto opOpAssign(string op)(T[] rhs) { mixin("return this.m_data" ~op~ "=rhs;"); } /// ditto
    auto opOpAssign(string op)(vector rhs) { mixin("return this.m_data" ~op~ "=rhs.data;"); } /// ditto

private:
    T[] m_data;

    // replaced by vector.data property
    //static p(M)(M m) { return cast(T[])m; }

    auto norm_sphere() const
    {
        T tmp = 0;
        this.m_data.each!(a => tmp += a * a);
        return round(sqrt(cast(real)tmp));
    }

    auto norm_octo() const
    {
        T tmp = 0;
        this.m_data.each!(a => tmp += abs(a));
        return tmp;
    }

    auto norm_cubic() const
    {
        T tmp = this.m_data[0];
        this.m_data.each!(a => (a>tmp)?(tmp=a):tmp);
        return tmp;
    }
}

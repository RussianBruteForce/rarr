module vector;

import std.math : sqrt, abs, round;
import std.algorithm.iteration : each;

debug = v;
debug(v) import std.stdio;

/++
    vector: class for math vector representation
+/

class vector(T)
{
    ///getter and setter for length of inner array
    @property size_t size() { return m_data.length; }
    /// ditto
    @property size_t size(size_t l) { return m_data.length = l; }
    /// pointer to inner array
    @property T[] data() { return m_data; };

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

    /// construct new vector through caaling class as a function
    static auto opCall(T[] data) { return new vector!T(data); }


    /// cast to array returns inner array
    auto opCast(type)() if (typeid(type) == typeid(T[])) { return this.m_data; }

    /// returns norm of type type
    auto norm(norm_t type)
    {
        switch(type)
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
        default:
            assert(0);
        }
    }

    /// getter and setter through the index i
    auto opIndex(size_t i) { return m_data[i]; }
    /// ditto
    auto opIndexAssign(T value, size_t i) { return m_data[i] = value; }

    //auto add(T value) { return this.m_data ~= value; }

    //auto add(T[] data) { return this.m_data ~= data; }

    /// apply op on each element of inner array
    auto opBinary(string op)(T rhs) //if (op == "*" || op == "+")
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
    auto opBinary(string op)(vector rhs) if (op == "*")
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
    auto opBinary(string op)(vector rhs) if (op == "+" || op == "-")
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

    auto norm_sphere()
    {
        T tmp = 0;
        this.m_data.each!(a => tmp += a * a);
        return round(sqrt(cast(real)tmp));
    }

    auto norm_octo()
    {
        T tmp = 0;
        this.m_data.each!(a => tmp += abs(a));
        return tmp;
    }

    auto norm_cubic()
    {
        T tmp = this.m_data[0];
        this.m_data.each!(a => (a>tmp)?(tmp=a):tmp);
        return tmp;
    }
}

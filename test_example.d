module main;

import std.stdio;
import std.typecons;
import rarr;

int main(string[] args)
{
    auto v = new vector!int([1,2,3]);
    auto m = new matrix!int([cast(int[])v,cast(int[])v,cast(int[])v]);
    writeln(cast(int[][])m.t());
    m*5;

    auto m1 = new matrix!int([[5,6],[8,9]]);
    auto m2 = new matrix!int([[1,2],[5,5]]);
    writeln(cast(int[][])(m1*m2));

    m1 *= m2;
    writeln(cast(int[][])(m1.t()));

    auto v1 = vector!int([1,1,1]);
    auto v2 = vector!int([3,3,3]);
    writeln(cast(int[])(v1 - v2));

    auto vn = vector!int([1,2,3]);
    writeln("norm ", vn.norm(vn.norm_t.cubic));
    vn ~= 666;
    vn ~= [9,8,7];
    vn ~= vector!int([1,2,3]);
    writeln(cast(int[])(vn));


    auto mn = matrix!int([[1,2],[3,4]]);
    writeln(mn.norm(mn.norm_t.cubic));
    writeln(mn.norm(mn.norm_t.octo));
    auto vm = mn*vector!int([5,6]);
    writeln(cast(int[])(vm));

    auto vt1 = vector!int("v1");
    auto mt1 = matrix!int("m1");


    auto vr1 = vector!int(5);
    writeln(cast(int[])(vr1.randomize()));
    auto mr1 = matrix!int(5);
    writeln(cast(int[][])(mr1.randomize()));
	return 0;
}

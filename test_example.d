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


    auto mn = matrix!float([[1,2],[3,4]]);
    writeln("norm ", mn.norm(mn.norm_t.cubic));
    writeln("norm ", mn.norm(mn.norm_t.octo));
    auto vm = mn*vector!int([5,6]);
    writeln(cast(int[])(vm));

    auto vt1 = vector!int("v1");
    auto mt1 = matrix!int("m1");


    auto vr1 = vector!int(5);
    writeln(cast(int[])(vr1.randomize(int.min, int.max)));
    auto mr1 = matrix!int(10);
    writeln(cast(int[][])(mr1.randomize(-10, 10)));

    auto vf = vector!int([666,666,666]);
    vf.save("kekv");
    mr1.save("kekm");
    auto mf = matrix!float("kekm");
    mf.save("kekmf");
    mr1 = matrix!int("kekmf");
    mf.save("kekm_");

    const auto gauss_m = new matrix!float([[2,1,-1],[-3,-1,2],[-2,1,2]]);
    const auto gauss_b = new vector!float([8,-11,3]);
    writeln("data A", gauss_m.cdata);
    writeln("data b", gauss_b.cdata);
    auto x1 = solve.gaussian(gauss_m, gauss_b);
auto multv = x1*x1;
    writeln("gauss x", x1.data);
    auto b1 = gauss_m * x1;
    writeln("gauss _b_", b1.data);
    writeln("residual is ", solve.residual(gauss_m, x1, gauss_b));

    writeln("data A ", gauss_m.cdata);
    writeln("data b ", gauss_b.cdata);
    auto x2 = solve.seidel(gauss_m, gauss_b, 12);
    writeln("seidel x", x2.data);
    auto b2 = gauss_m * x2;
    writeln("seidel _b_", b2.data);
    writeln("residual is ", solve.residual(gauss_m, x2, gauss_b));

    return 0;
}

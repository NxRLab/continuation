(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



(*
ArticulatedBodyAlgorithm.nb: An implementation of the ABA algorithm
and its derivative.
Copyright (C) 2014 Nelson Rosa Jr.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version. This program is distributed in the 
hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details. You should have 
received a copy of the GNU General Public License along with this program.
If not, see <http://www.gnu.org/licenses/>.
*)


BeginPackage["NLink`"]
Begin["`Private`"]


(* 
user inputs: x, u;
zeroed inputs: c, v, a, f, IC;
model data: ag, \[DoubleStruckCapitalI], parent, nq;
modifies: c, v, a, f, qdd, U, uJ, d;
output: qdd (joint-space accelerations)
*)
ABA[x_, u_] := Module[{vJ, p, Ic, fc},
(* clear/set spatial variables *)
v = Zspat; (* spatial velocity *)
a = Zspat; (* spatial acceleration *)
f = Zspat; (* spatial force *)
IC = \[DoubleStruckCapitalI]; (* articulated body inertia *)

(* clear/set ABA variables *)
c = Zspat; (* spatial velocity products *)
U = Zspat;
d = znq;
uJ = znq; (* joint force *)
qdd = znq; (* C-space accelerations *)

Do[
p = parent[[i]];
vJ = sJ[[i]] x[[nq+i]];
If[p == 0,
v[[i]] = vJ;
(*c\[LeftDoubleBracket]i\[RightDoubleBracket] = z6;*),
v[[i]] = XL[[i]].v[[p]] + vJ;
c[[i]] =  mx[v[[i]]].vJ  + sJdot[[i]] x[[nq+i]];
];
(*IC\[LeftDoubleBracket]i\[RightDoubleBracket] = \[DoubleStruckCapitalI]\[LeftDoubleBracket]i\[RightDoubleBracket];
f\[LeftDoubleBracket]i\[RightDoubleBracket] = mxstar[v\[LeftDoubleBracket]i\[RightDoubleBracket]].(\[DoubleStruckCapitalI]\[LeftDoubleBracket]i\[RightDoubleBracket] .v\[LeftDoubleBracket]i\[RightDoubleBracket]);*)
f[[i]] = mxstar[v[[i]]].(IC[[i]] .v[[i]]); (* bias force *)
,{i, nq}];

Do[
U[[i]] = IC[[i]].sJ[[i]];
d[[i]] = sJ[[i]].U[[i]];
uJ[[i]] = u[[i]] - sJ[[i]].f[[i]];

p = parent[[i]];
If[p != 0,
Ic = IC[[i]] - tensprod[U[[i]]/d[[i]], U[[i]]];
IC[[p]] = IC[[p]] +  XL[[i]]\[Transpose].Ic.XL[[i]];

fc = f[[i]] + Ic.c[[i]] + U[[i]]uJ[[i]]/d[[i]];
f[[p]] = f[[p]] +  XL[[i]]\[Transpose].fc;
];
, {i, nq, 1, -1}];

Do[
p = parent[[i]];
If[p == 0,
a[[i]] = XL[[i]].ag + c[[i]];,
a[[i]] = XL[[i]].a[[p]] + c[[i]];
];
qdd[[i]] = (uJ[[i]] - U[[i]].a[[i]])/d[[i]];
a[[i]] = a[[i]] + sJ[[i]]qdd[[i]];
, {i, nq}];
];


Faba[x_, u_] := Module[{},
(* initialize variables *)
XL = Xip[x]; (* parent to child transforms *)
sJ = s[x]; (* link motion freedoms *)
sJdot = sdot[x]; (* time derivative of sJ *)

ABA[x,u]; (* computes qdd *)
qdd
];


ABACode = {
cargs:>{{x, _Real, 1}, {u, _Real, 1}},
ccode:>
(
znq = znqarr;
Zspat = Zspatarr;
parent = pararr;
\[DoubleStruckCapitalI] = \[DoubleStruckCapitalI]arr;

Faba[x, u];
Join[x[[nq+1;;nx]], qdd]
)};


End[]
EndPackage[]

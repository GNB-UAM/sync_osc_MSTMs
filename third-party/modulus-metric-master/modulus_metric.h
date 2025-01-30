/*
This file includes C++ implementations of the modulus-metric distance between two spike trains, 
as defined in the following paper:

Rusu, C. V., & Florian, R. V. (2014). A new class of metrics for spike trains. 
Neural Computation, 26(2), 306–348. doi:10.1162/NECO_a_00545

Preprint: arXiv:1209.2918


################################################################################
# (C) R. V. Florian & C. V. Rusu, 2012
#
# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), to deal 
# in the Software without restriction, including without limitation the rights 
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
# of the Software, and to permit persons to whom the Software is furnished to do 
# so, subject to the following conditions:
#
# 1. If you publish scientific papers based on work that uses the Software, you 
# should consider citing within these papers the following:
#
# Rusu, C. V., & Florian, R. V. (2014). A new class of metrics for spike trains. 
# Neural Computation, 26(2), 306–348. doi:10.1162/NECO_a_00545
#
# 2. If you create derivative works using the Sofware and these works have an associated
# list of contributors, you must attribute the work of R. V. Florian and C. V. Rusu according 
# to the relevance of the Software to the derivative works.
#
# The above copyright notice and this permission notice shall be included in all 
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
# FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT 
# OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
# DEALINGS IN THE SOFTWARE.
#
################################################################################

*/

#pragma once

#include <vector>
#include <tuple>
#include <algorithm>

typedef std::vector<double> SPIKE_TRAIN;

/* Modulus-metric, optimized implementation (Algorithm 2) */

double d(int t, SPIKE_TRAIN &T, int i){
        //Input:  a timing t, a sorted spike train T and an index i of a spike in T
        //        such that either t <= T[i] or i is the index of the last spike of T
        //Output: the distance d(t, T) between a timing t and a spike train T
        double db = abs(T[i] - t);
        int j = i - 1;
        while (j >= 0 && abs(T[j] - t) <= db) {
            db = abs(T[j] - t);
            j -= 1;
        }
        return db;
}

double do_measure_optimal (SPIKE_TRAIN T1, SPIKE_TRAIN T2, double a, double b) {
    using namespace std;

    //T1 and T2 are ordered, nonempty sets of real numbers, indexed starting from 0.
    //i1 and i2 are the indices of the currently processed spikes in the two spike
    //trains. p1 and p2 are the indices of the previously processed spikes in the
    //two spike trains. p is the index of the spike train to which the previously
    //processed spike belonged (1 or 2), after at least one spike has been processed,
    //or 0 otherwise.

    int i1 = 0, i2 = 0, p1 = 0, p2 = 0, p = 0;
    int n1 = T1.size (), n2 = T2.size ();

    //P is an array of structures (s,phi) consisting of a ordered pair of numbers.
    vector <tuple<double,double> > P;
    P.reserve(3*(n1 + n2));
    P.push_back (make_tuple (a, abs(T1[0] - T2[0])));

    double t = 0.0;
    //Process the spikes until the end of one of the spikes trains is reached.
    while (i1 < n1 && i2 < n2) {
        if (T1[i1] <= T2[i2]){
            if (i1 > 0) {
                //Adds to P the timing situated at the middle of the interval between the
                //currently processed spike and the previous spike in the same spike train.
                t = (T1[i1] + T1[i1 - 1]) / 2.0;
                //We have d(t, T1) = T1[i1] - t = t - T1[i1 - 1] = (T1[i1] - T1[i1 - 1]) / 2.
                P.push_back (make_tuple (t, abs((T1[i1] - T1[i1 - 1]) / 2.0 - d(t,T2,i2))));
            }
            if (p == 2) {
                //If the previously processed spike was one from the other spike train than
                //the spike currently processed, adds to P the timing situated at the
                //middle of the interval between the currently processed spike and the
                //previously processed spike.
                t = (T1[i1] + T2[p2]) / 2.0;
                //Since t is is at equal distance to the closest spikes in the two spike
                //trains, T1[i1] and T2[p2], we have d(t, T1)=d(t, T2) and phi(t)=0.
                P.push_back (make_tuple (t, 0));
            }
            //Adds to P the currently processed spike.
            t = T1[i1];
            //We have d(t, T1) = 0. If at least one spike from T2 has been processed, we
            //have T2[p2] <= t <= T2[i2], with i2 = p2 + 1, and thus
            //d(t, T2) = min(|t-T2[p2]|, T2[i2]-t). If no spike from T2 has been processed,
            //we have p2 = i2 = 0, and the previous formula for d(t, T2) still holds.
            P.push_back (make_tuple (t, min(abs(t - T2[p2]), T2[i2] - t)));
            p1 = i1;
            i1 += 1;
            p = 1;
        }
        else {
            //Proceed analogously for the case T1[i1] > T2[i2]:
            if (i2 > 0) {
                t = (T2[i2] + T2[i2 - 1]) / 2.0;
                P.push_back (make_tuple (t, abs((T2[i2] - T2[i2 - 1]) / 2.0 - d(t,T1,i1))));
            }
            if (p == 1) {
                t = (T2[i2] + T1[p1]) / 2.0;
                P.push_back (make_tuple (t, 0));
            }
            t = T2[i2];
            P.push_back (make_tuple (t, min(abs(t - T1[p1]), T1[i1] - t)));
            p2 = i2;
            i2 += 1;
            p = 2;
        }
    }
    //Process the rest of the spikes in the spike train that has not been fully
    //processed:
    while (i1 < n1) {
            if (i1 > 0) {
                //Adds to P the timing situated at the middle of the interval between the
                //currently processed spike and the previous spike in the same spike train
                t = (T1[i1] + T1[i1 - 1]) / 2.0;
                //We have d(t, T1) = T1[i1] - t = t - T1[i1 - 1] = (T1[i1] - T1[i1 - 1]) / 2.
                P.push_back (std::make_tuple (t, abs((T1[i1] - T1[i1 - 1]) / 2.0 - d(t,T2,p2))));
            }
            if (p == 2) {
                //If the previously processed spike was one from the other spike train than
                //the spike currently processed (i.e., the last spike in the spike train
                //that has been fully processed), adds to P the timing situated at the
                //middle of the interval between the currently processed spike and the
                //previously processed spike.
                t = (T1[i1] + T2[p2]) / 2.0;
                //Since t is is at equal distance to the closest spikes in the two spike
                //trains, T1[i1] and T2[p2], we have d(t, T1)=d(t, T2) and phi(t)=0.
                P.push_back (std::make_tuple (t, 0));
            }
            //Adds to P the currently processed spike.
            t = T1[i1];
            //We have d(t, T1) = 0. We have T2[p2] <= t and the spike at p2 ist the last one
            //in T2, and thus d(t, T2) = t - T2[p2].
            P.push_back (std::make_tuple (t, t - T2[p2]));
            //p1 = i1 #This could be added for completeness, but it is not used by this algorithm.
            i1 += 1;
            p = 1;
    }
    while  (i2 < n2){
            //Proceed analogously for the case that the train that has not been fully processed
            //is T2:
            if (i2 > 0) {
                t = (T2[i2] + T2[i2 - 1]) / 2.0;
                P.push_back (std::make_tuple (t, abs((T2[i2] - T2[i2 - 1]) / 2.0 - d(t,T1,p1))));
            }
            if (p == 1) {
                t = (T2[i2] + T1[p1]) / 2.0;
                P.push_back (std::make_tuple (t, 0));
            }
            t = T2[i2];
            P.push_back (std::make_tuple (t, t - T1[p1]));
            //p2 = i2
            i2 += 1;
            p = 2;
    }
    P.push_back (std::make_tuple (b, abs(T1[n1 - 1] - T2[n2 - 1])));
    //sort P with regard to the first element
    sort (P.begin (), P.end());

    unsigned int psize = P.size ();

    //perform the integration
    double dO = 0.0;
    for (unsigned int i = 1; i < psize; ++i)
        dO += (std::get<0>(P[i]) - std::get<0>(P[i-1])) * (std::get<1>(P[i]) + std::get<1>(P[i-1])) / 2.0;

    return dO;
}


/* Modulus-metric, quick and dirty implementation (Algorithm 1) */

double do_measure_naive (SPIKE_TRAIN T1, SPIKE_TRAIN T2, double a, double b) {
   unsigned int n1 = T1.size ();
   unsigned int n2 = T2.size ();

    //T1, T2, P are ordered sets of real numbers, index starting from 0. If P is
    //not automatically sorted, it should be explicitly sorted

    std::vector <double> P;
    P.reserve(n1 + n2); // preallocate memory
    P.insert( P.end(), T1.begin(), T1.end() );
    P.insert( P.end(), T2.begin(), T2.end() );
    sort (P.begin (), P.end());

    std::vector <double> M;

    for (unsigned int i = 1; i < P.size(); ++i)
        M.insert (M.end(), (P[i] + P[i-1])/2.0);

    for (unsigned int i = 1; i < n1; ++i)
        M.insert (M.end(), (T1[i] + T1[i-1])/2.0);

    for (unsigned int i = 1; i < n2; ++i)
        M.insert (M.end(), (T2[i] + T2[i-1])/2.0);

    P.insert( P.end(), M.begin(), M.end() );
    P.insert( P.end(), a); P.insert( P.end(), b);
    sort (P.begin (), P.end());

    double dO = 0.0;
    unsigned int i1 = 0, i2 = 0;

    //s is the currently considered point from P. f is the value at s of the
    //integrated function |d(s,T1)-d(s,T2)|. sp is the previously considered point
    //from P, and fp is the value at spof the integrated function. i1 is the index
    //of the first spike in T1 having a timing that is greater than s, if there is
    //such a spike, or the index of the last spike of T1, otherwise. i2 is computed
    //analogously for T2
    double sp = P[0], fp = 0.0;

    double d1p = 0.0;
    double d2p = 0.0;
    double f = 0.0;

    //print_v (P);

    for (unsigned int i = 0; i < P.size(); ++i) {
        double s = P[i];

        while (s >= T1[i1] && i1 < n1 - 1)
            i1 += 1;
        while (s >= T2[i2] && i2 < n2 - 1)
            i2 += 1;

        double d1 = b - a; double d2 = b - a;

        if (i1 > 0)
            d1 = s - T1[i1 - 1];
        d1p = abs (T1[i1] - s);
        if (d1p < d1)
            d1 = d1p;

        if (i2 > 0)
            d2 = s - T2[i2 - 1];
        d2p = abs (T2[i2] - s);
        if (d2p < d2)
            d2 = d2p;

        //we can now compute the value of f at s
        f = abs (d1 - d2);

        //the integration is performed here
        dO += (s - sp) * (f + fp) / 2.0;

        sp = s; fp = f;
    }

    return dO;
}


/* Modulus-metric, brute force implementation - for testing only, do not use in applications */

double d1 (int t, SPIKE_TRAIN &T){
    //input:  a timing t and a sorted spike train T
    //output: the distance d(t, T) between a timing t and a spike train T
    double infT = std::numeric_limits<double>::max();

    double db = 0;

    for (unsigned int j = 0; j < T.size (); ++j) {
        db =  abs (t - T[j]);
        if (db < infT)
            infT = db;
    }
    return infT;
}

double do_measure_bruteforce (SPIKE_TRAIN T1, SPIKE_TRAIN T2, double a, double b) {
    //T1 and T2 are ordered, nonempty sets of real numbers, indexed starting from 0.
    double dO = 0.0; double dt = .01;

    for (double i = a; i < b; i+= dt)
        dO += abs (d1 (i, T1) - d1 (i, T2))*dt;

    return dO;
}

using Plots, Measures
using Colors
using LaTeXStrings
using Printf
import Plots: bar, plot, savefig, title!

# data
pairs = [(8,32)	(8,16)	(4,16) (2,16) (4,8) (2,8)]
benchmarks = ["mcf", "lbm", "soplex", "milc", "oment", "bwaves", "gcc", "libquant", "sphinx", "gems"]
wb_base = [2169.4	2951.8	1656.2	1580.4	1920.2	1245;
           1886.6	2542.4	1450.2	961.4	1642	1025.2;
           2211.0	3097.1	1848.4	1240.7	2106.6	1312.9;
           2705.7	3370.1	1989.6	1256.1	2185.4	1410.5;
           3001.0	3915.6	2236.7	1370.1	2495.0	1532.5;
           2735.9	3544.6	2148.7	1446.1	2334.1	1597.6;
           2241.3	2912.1	1769.3	1618.5	1897.4	1148;
           1099.0	1469.3	920	588.7	965.6	699;
           1734.9	2163.5	1305.4	947.2	1585.4	1011;
           2747.9	3732.7	2182.7	1457.7	2365.7	1557.3]

wb_buffer = [1706.0	1932.4	1281.8	1261.0	1415.8	935.8;
             1377.8	1676.4	1133.8	802.2	1213.6	836.4;
             1913.0	2297.8	1485.2	1085.4	1808.4	1148.6;
             2016.4	2509.8	1518.9	1021.3	1555.4	1137.8;
             1763.5	2099.8	1369.0	955.9	1499.8	1163.0;
             2177.7	2739.3	1792.2	1317.2	1943.3	1348.6;
             1355.9	1667.5	1142	1058.1	1154.4	790.2;
             905.1	935.5	721.3	508.0	688.1	568.1;
             1602	1911.3	1215.4	933.9	1475.5	969.3;
             2171.5	2861.2	1776.8	1219	1877.9	1371.8]

speedup = (wb_base .- wb_buffer) ./ wb_base

# very hacky way to include master title: https://stackoverflow.com/questions/43066957/adding-global-title-to-plots-jl-subplots
# create a transparent scatter plot with an 'annotation' that will become title
y = ones(3) 
title = Plots.scatter(y, marker=0,markeralpha=0, annotations=(2, y[2], Plots.text("Speedup introduced by write buffer for various pairs of (WORD_PER_BLOCK, CACHE_SIZE_WORD)")),axis=false, grid=false, leg=false,size=(200,100))

# combine the 'title' plot with your real plots
Plots.plot(
    title,
    plot(x, speedup,layout=grid(3,2), legend=false, seriestype=:bar, title=map(string, pairs), size=(1200, 1200)),
    layout=grid(2,1,heights=[0.1,0.9])
)

savefig("myplot.png")

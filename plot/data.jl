import Plots, Printf, Colors, Measures
using Plots: bar, plot, savefig, title!, grid, @layout

# the pairs of (WORD_PER_BLOCK, CACHE_SIZE_WORD)
pairs = [(2,8) (4,8) (2,16) (4,16) (8,16)]

# the benchmarks
benchmarks = ["mcf", "lbm", "soplex", "milc", "oment", "bwaves", "gcc", "libquant", "sphinx", "gems"]
benchmark_load_percentages = [30.60 26.30 38.90 37.30 34.20 46.50 25.60 14.40 30.40 45.10] ./ 100
benchmark_store_percentages = [8.60 8.50 7.50 10.70 17.90 8.50 13.10 5.00 3.00 10.00] ./ 100

# test data from ../baseline-text
# 5 columns: len(pairs) = 5
# 10 rows: 10 testbenches
wt_buffer = [928.95	1342.1	916.75	1217.35	1961.6
             828.8	1142.7	784.95	1028.15	1646.3
             1145.05	1692.2	1082.45	1507.35	2342.85
             1106.5	1614.15	1039.1	1447.05	2191.15
             1037.25	1462.75	983.1	1354.9	2104.95
             1368.8	1973.85	1263.65	1782.9	2792.8
             827.45	1147.9	795.6	1022.6	1589.45
             538.1	699.1	527.4	667.9	998.35
             966.1	1350.7	919.65	1253.55	1871.55
             1341.6	1927.7	1261.5	1721.05	2794.55
             ]

wt_base = [1097.7	1586.95	1029.45	1435.2	2355.55
           992.55	1414.55	929.6	1239.65	2092.1
           1223.05	1836.8	1148.95	1638.7	2612.4
           1289.45	1919.85	1191.6	1688	2675.55
           1451.45	2116.8	1375.05	1950.25	3094.75
           1470.65	2186.1	1349.5	1957.65	3201.25
           1140.6	1630.55	1073.8	1458.95	2321
           645.8	866	615.7	809.75	1273.65
           923.35	1331.9	876.15	1235.1	1904.45
           1490.4	2198.1	1390.8	1974.95	3290.2
           ]

wb_buffer = [959.45	1378.4	906.85	1211.2	2030.95
             831.7	1153.8	765.25	1054.3	1616.8
             1168.4	1609.95	1080.9	1471.5	2352.9
             1111.5	1574.55	1074.2	1467.25	2286.4
             1031.75	1467.6	970.85	1318.3	2201.2
             1362.35	1986.95	1282.15	1790.2	2819.75
             830.3	1148.35	795.5	1081	1742.05
             530.75	688.05	515.85	686.3	982.6
             950.2	1340.35	901.45	1251.15	1978.7
             1325.15	1866.9	1228.95	1704.65	2805.05
             ]

wb_base = [1144.75	1804.95	1052.2	1537.25	2677.65
           1030.25	1567.5	919.45	1393.75	2368.1
           1286.55	1929.25	1160.8	1727.75	2874.15
           1353.8	2091.15	1255.65	1927.05	3193.8
           1569.1	2478.3	1414.95	2144.7	3816.1
           1509.45	2357.55	1391.6	2108.15	3539.25
           1208.45	1877.05	1108.2	1680.35	2926.75
           639.05	925.1	625.3	885.35	1371.2
           909.55	1353.65	869.8	1261.9	2011.5
           1529.3	2365	1389.8	2107.25	3613.05
           ]

# compute speed up
wb_speedup = wb_base ./ wb_buffer
wt_speedup = wt_base ./ wt_buffer

# layout for the plots
l = @layout [° °; ° °; ° _]

function plot_bar_charts(speedup, fn, cache_type)
    # bar charts
    # very hacky way to include master title: https://stackoverflow.com/questions/43066957/adding-global-title-to-plots-jl-subplots
    # create a transparent scatter plot with an 'annotation' that will become title
    x = Matrix{String}(undef, 10, 5)
    for i in 1:10
        for j in 1:5
            x[i,j] = benchmarks[i]
        end
    end
    y = ones(3) 
    title = Plots.scatter(y, marker=0,markeralpha=0, annotations=(2, y[2], Plots.text("Speedup introduced by write buffer for various pairs of (WORD_PER_BLOCK, CACHE_SIZE_WORD)\n($cache_type)")),axis=false, grid=false, leg=false,size=(200,100))

    # combine the 'title' plot with your real plots
    Plots.plot(
        title,
        plot(x, speedup,layout=l, legend=false, seriestype=:bar, title=map(string, pairs), size=(1200, 1200), xlabel="benchmark", ylabel="speedup"),
        layout=grid(2,1,heights=[0.1,0.9])
    )
    savefig(fn)
end

function plot_compare_store(speedup, fn, cache_type)
    x = Matrix{Float64}(undef, 10, 5)
    for i in 1:10
        for j in 1:5
            x[i,j] = benchmark_store_percentages[i]
        end
    end
    y = ones(3) 
    title = Plots.scatter(y, marker=0,markeralpha=0, annotations=(2, y[2], Plots.text("Speedup introduced by write buffer for various pairs of (WORD_PER_BLOCK, CACHE_SIZE_WORD)\n($cache_type)")),axis=false, grid=false, leg=false,size=(200,100))

    # combine the 'title' plot with your real plots
    Plots.plot(
        title,
        plot(x, speedup,layout=l, legend=false, seriestype=:scatter, title=map(string, pairs), size=(1200, 1200), xlabel="store instruction percentage", ylabel="speedup"),
        layout=grid(2,1,heights=[0.1,0.9])
    )
    savefig(fn)
end

function plot_all()
    plot_bar_charts(wb_speedup, "wb_bar.png", "write back")
    plot_compare_store(wb_speedup, "wb_scatter.png", "write back")
    plot_bar_charts(wt_speedup, "wt_bar.png", "write through")
    plot_compare_store(wt_speedup, "wt_scatter.png", "write through")
    plot_bar_charts(wb_speedup .- wt_speedup, "wb-wt.png", "write back - write through")
end

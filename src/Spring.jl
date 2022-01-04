module Spring
using Plots
    toto(x) = cos(x)

    function gogo()
        x=[Float64(i) for i ∈ 1:40]
        y=toto.(x)
        plot(x,y)
    end

end # module

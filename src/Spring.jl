module Spring #correspond à un namespace
    using Plots

    export SpringParam, InitParam, AnimParam
    export animate_spring

    toto(x) = cos(x)

    function gogo()
        x=[Float64(i) for i ∈ 1:60]
        y=toto.(x)
        plot(x,y)
    end

    Base.@kwdef struct SpringParam
        ls::Float64
        ms::Float64
        ks::Float64
        ns::Int
    end
    #A quoi sert Base.@kwdef? A rentrer des champs nommés
    getvalue(p::SpringParam) = p.ls,p.ms,p.ks,p.ns

    Base.@kwdef struct InitParam
        λ::Float64
        shift::Float64
        pos::Float64
    end
    getvalue(p::InitParam) = p.λ,p.shift,p.pos
    #meme nom de methode mais argument specialise

    Base.@kwdef struct AnimParam
        δt::Float64
        nδt::Int
        nδtperframe::Int
    end
    getvalue(p::AnimParam) = p.δt,p.nδt,p.nδtperframe

    steady_position(i,ls) = (i-1)*ls 

    function initial_position(i,ls,λ,shift,pos)
        xs=steady_position(i,ls)
        dx=xs-pos
        xs-λ*dx*shift*exp(-0.5*dx^2/λ^2)
    end

    function update_force!(fx,xc,ks) # ! est une convention de nommage en julia
                                     # pour les fonctions dont on modifie les arguments 
                                     # placés en premieres positions
        ns=length(xc)
        for i ∈ 2:ns-1
            fx[i] = -ks*(2xc[i]-xc[i-1]-xc[i+1])
        end
    end

    function update_position!(xt,xc,xp,fx,δt,ms)
        coef=δt^2/ms
        @. xt = 2*xc - xp + fx*coef
    end

    function advance_nδtpf(xc,xp,xt,fx,sp,ap)
        ls,ms,ks,ns=getvalue(sp)
        δt,nδt,nδtperframe=getvalue(ap)

        for _ ∈ 1:nδtperframe #boucle sans indice
            update_force!(fx,xc,ks)
            update_position!(xt,xc,xp,fx,δt,ms)
            xc,xp,xt=xt,xc,xp
        end
        xc,xp,xt
    end

    function animate_spring(sp,ip,ap)
        ls,ms,ks,ns=getvalue(sp)
        λ,shift,pos=getvalue(ip)
        δt,nδt,nδtperframe=getvalue(ap)

        xs=[steady_position(i,ls) for i ∈ 1:ns] #array comprehension
        xc=[initial_position(i,ls,λ,shift,pos) for i ∈ 1:ns]

        dc=zero(xc) #tableau de la meme forme et meme type que xc avec des 0
        #for i ∈ 1:ns
        #    dc[i]=xc[i]-xs[i]
        #end
        #version broadcastée, pas de difference de rapidité en julia
        #dc.=xc.-xs
        #autre notation pour ne pas mettre des . partout
        #@. dc=xc-xs

        fx=zero(xc)
        #update_force!(fx,xc,ks)

        xt=zero(xc)
        xp=copy(xc) #sinon ca pointe juste, on change de nom
        #example tester a=rand(2), b=rand(3), a,b=b,a
        nf=nδt÷nδtperframe
        t=0.0 
        anim = @animate for i ∈ 1:nf #creation d'une animation
            xc,xp,xt=advance_nδtpf(xc,xp,xt,fx,sp,ap)
            @. dc = xc - xs
            t+=nδtperframe*δt
            plot(xs,dc,ylims=(-shift,shift),title="t=$t")
        end            
        gif(anim,"toto.gif",fps=15)
        
        #plot(xs,fx)
        #plot(xs,dc)

        #imid=ns÷2 #division entiere \div
        #xs[imid],xc[imid],dc[imid]
        #sp,ip,ap #retour de la fonction main
    end

    # si on laisse main ici il faut l'appeler avec Spring.main() dans le REPL
    # ou l'exporter du module pour s'affranchir du Spring.
    # Mieux faire un fichier main.jl à la racine puis dans le REPL include("main.jl")
    #function main()
    #    sp=Spring.SpringParam(ls=0.1,ms=1,ks=1,ns=400)
    #    ip=InitParam(λ=1.0,shift=1.5,pos=sp.ls*sp.ns/2)
    #    ap=AnimParam(δt=1.0,nδt=1000,nδtperframe=10)

    #end

end # module

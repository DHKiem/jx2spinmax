# jx2spinmax

Install:
```
julia> ]
pkg> add https://github.com/DHKiem/jx2spinmax.git
```

Usage: 
```
julia> import jx2spinmax
julia> jx2spinmax.create([1,2,3], [1,2,3], "./jx2.col.spin_0.0")
julia> jx2spinmax.create([1,2,3], [1,2,3], "./jx2.col.spin_0.0", toml = "MFT.toml")
```

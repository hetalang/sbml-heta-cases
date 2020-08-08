heta build
export heta_version=`heta -v`
julia_path="C:/Users/evgen/AppData/Local/Programs/Julia 1.5.0/bin/"
"${julia_path}julia" ./run.jl $heta_version
echo "READY!"

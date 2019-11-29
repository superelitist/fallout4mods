$compiler_path="C:\code\toolchain_papyrus\Caprica\Caprica.exe"
$compiler_include_path="C:\code\toolchain_papyrus\scripts"
$compiler_flags_path="C:\code\toolchain_papyrus\Caprica\FO4_Papyrus_Flags.flg"
$script_path="C:\code\fallout4mods"
$script_namespace="armamentarium"
$output_path="C:\code\build"

& $compiler_path @("$script_path\$script_namespace", "-i", $compiler_include_path, "-f", $compiler_flags_path, "-o", "$output_path\$script_namespace")
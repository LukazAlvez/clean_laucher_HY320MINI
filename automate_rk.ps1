Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Text;

public class Win32 {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll")]
    public static extern bool EnumChildWindows(IntPtr hWndParent, EnumWindowsProc lpEnumFunc, IntPtr lParam);

    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, string lParam);

    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern int GetDlgCtrlID(IntPtr hWnd);
}
"@

$hwnd = [Win32]::FindWindow($null, "RKDevTool v2.86")
Write-Output ("RKDevTool HWND: " + $hwnd)
if ($hwnd -ne [IntPtr]::Zero) {
    [Win32]::EnumChildWindows($hwnd, {
        param($child, $lparam)
        $sbText = New-Object System.Text.StringBuilder 256
        $sbClass = New-Object System.Text.StringBuilder 256
        [Win32]::GetWindowText($child, $sbText, 256) | Out-Null
        [Win32]::GetClassName($child, $sbClass, 256) | Out-Null
        $id = [Win32]::GetDlgCtrlID($child)
        $t = $sbText.ToString()
        $c = $sbClass.ToString()
        if ($t -ne '' -or $c -match 'Edit|Button') {
            Write-Output ("Handle: $child | ID: $id | Class: $c | Text: $t")
        }
        return $true
    }, [IntPtr]::Zero)
}

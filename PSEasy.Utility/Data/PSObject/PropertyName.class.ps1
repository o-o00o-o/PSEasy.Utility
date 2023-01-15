class PropertyName {
    # unfortunately it seems that we can't extend value types here (otherwise we would just extend system.string, so this is the next best thing)
    [string] $Value

    PropertyName([string]$Value) {
        $this.Value = $Value
    }

    hidden static [PropertyName] op_Implicit([string]$Value) {
        return [PropertyName]::new($Value)
    }

    hidden static [String] op_Implicit([PropertyName]$PropertyName) {
        return $PropertyName.Value
    }

    [string] ToString() {
        return $this.Value
    }

    [bool] Equals([System.Object] $obj) {
        return $this.Value -eq $obj.ToString()
    }
}

locals {
  name_clean = replace(var.name, "-", "")
  has_dash   = can(regex("-", var.name))
  segments   = split("-", var.name)

  # Segment abbreviations: try progressively more characters per segment (most readable that fits)
  abbr_3 = join("", [for seg in local.segments : substr(seg, 0, 3)])
  abbr_2 = join("", [for seg in local.segments : substr(seg, 0, 2)])
  abbr_1 = join("", [for seg in local.segments : substr(seg, 0, 1)])

  from_segments = (
    length(local.abbr_3) <= var.max_length ? local.abbr_3 :
    length(local.abbr_2) <= var.max_length ? local.abbr_2 :
    length(local.abbr_1) <= var.max_length ? local.abbr_1 :
    substr(local.name_clean, 0, var.max_length)
  )

  # Derived short name: segment abbreviations if dashes present, prefix truncation otherwise
  derived = local.has_dash ? local.from_segments : substr(local.name_clean, 0, var.max_length)

  result = (
    length(local.name_clean) <= var.max_length ? local.name_clean :
    var.short_name != null ? var.short_name :
    local.derived
  )
}

output "name" {
  value = local.result
}

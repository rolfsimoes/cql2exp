
# ---- advanced comparison operators ----

# - cql2_like_op
# - cql2_between_op
# - cql2_inlist_op

# ---- constructor functions ----

# like_op
like_op <- function(a, b) {
    a <- cql2_eval(a)
    b <- cql2_eval(b)
    stopifnot(is_str_expr(a))
    stopifnot(is_patt_expr(b))
    structure(list(op = "like", args = list(a, b)), class = "cql2_like_op")
}

# between_op
between_op <- function(a, b, c) {
    a <- cql2_eval(a)
    b <- cql2_eval(b)
    c <- cql2_eval(c)
    stopifnot(is_num_expr(a))
    stopifnot(is_num_expr(b))
    stopifnot(is_num_expr(c))
    structure(list(op = "between", args = list(a, b, c)),
              class = "cql2_between_op")
}

# in_op
in_op <- function(a, b) {
    a <- cql2_eval(a)
    b <- cql2_eval(b)
    stopifnot(is_scalar(a))
    stopifnot(is_scalar_lst(b))
    structure(list(op = "in", args = list(a, b)), class = "cql2_in_op")
}

# spatial_op
spatial_op <- function(op) {
    function(a, b) {
        a <- cql2_eval(a)
        b <- cql2_eval(b)
        stopifnot(is_spatial_expr(a))
        stopifnot(is_spatial_expr(b))
        if (is_spatial(a))
            a <- get_spatial_sfc(a)
        if (is_spatial(b))
            b <- get_spatial_sfc(b)
        structure(list(op = op, args = list(a, b)),
                  class = "cql2_spatial_op")
    }
}

get_spatial_sfc <- function(geom) {
    return(geom)
}

# temporal_op
temporal_op <- function(op) {
    function(a, b) {
        a <- cql2_eval(a)
        b <- cql2_eval(b)
        stopifnot(is_temporal_expr(a))
        stopifnot(is_temporal_expr(b))

        structure(list(op = op, args = list(a, b)),
                  class = "cql2_temporal_op")
    }
}

# ---- environment ----

cql2_adv_comp_env <- new_env(
    `%like%` =       like_op,
    `between` =      between_op,
    `%in%` =         in_op,
    s_intersects =   spatial_op("s_intersects"),
    s_contains =     spatial_op("s_contains"),
    s_crosses =      spatial_op("s_crosses"),
    s_disjoint =     spatial_op("s_disjoint"),
    s_equals =       spatial_op("s_equals"),
    s_overlaps =     spatial_op("s_overlaps"),
    s_touches =      spatial_op("s_touches"),
    s_within =       spatial_op("s_within"),
    t_after =        temporal_op("t_after"),
    t_before =       temporal_op("t_before"),
    t_contains =     temporal_op("t_contains"),
    t_disjoint =     temporal_op("t_disjoint"),
    t_during =       temporal_op("t_during"),
    t_equals =       temporal_op("t_equals"),
    t_finishedby =   temporal_op("t_finishedby"),
    t_finishes =     temporal_op("t_finishes"),
    t_intersects =   temporal_op("t_intersects"),
    t_meets =        temporal_op("t_meets"),
    t_metby =        temporal_op("t_metby"),
    t_overlappedby = temporal_op("t_overlappedby"),
    t_overlaps =     temporal_op("t_overlaps"),
    t_startedby =    temporal_op("t_startedby"),
    t_starts =       temporal_op("t_starts"),
    global_env =     cql2_global_env
)

# ---- convert to json ----

#' @exportS3Method
to_json.cql2_like_op <- function(x) json_obj(x)

#' @exportS3Method
to_json.cql2_between_op <- function(x) json_obj(x)

#' @exportS3Method
to_json.cql2_in_op <- function(x) json_obj(x)

# ---- convert to text ----

# is there infix NOT operator?
# like_op
#' @exportS3Method
text_not_op.cql2_like_op <- function(x)
    paste(to_text(x$args[[1]]$args[[1]]), "NOT LIKE",
          to_text(x$args[[1]]$args[[2]]))

#' @exportS3Method
to_text.cql2_like_op <- function(x)
    paste(to_text(x$args[[1]]), toupper(x$op), to_text(x$args[[2]]))

# between_op
#' @exportS3Method
text_not_op.cql2_between_op <- function(x)
    paste(to_text(x$args[[1]]$args[[1]]), "NOT BETWEEN",
          to_text(x$args[[1]]$args[[2]]), "AND",
          to_text(x$args[[1]]$args[[3]]))

#' @exportS3Method
to_text.cql2_between_op <- function(x)
    paste(to_text(x$args[[1]]), "BETWEEN",
          to_text(x$args[[2]]), "AND", to_text(x$args[[3]]))

# in_op
#' @exportS3Method
text_not_op.cql2_in_op <- function(x)
    paste(to_text(x$args[[1]]$args[[1]]), "NOT IN",
          to_text(x$args[[1]]$args[[2]]))

#' @exportS3Method
to_text.cql2_in_op <- function(x)
    paste(to_text(x$args[[1]]), "IN", to_text(x$args[[2]]))

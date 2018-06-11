use syntax::parse::parser::{PathStyle, Parser};
use syntax::parse::{SeqSep, PResult};
use syntax::ast::Path;
use syntax::parse::token::Token::{Eof, Comma};

pub trait ParserExt<'a> {
    fn parse_paths(&mut self) -> PResult<'a, Vec<Path>>;
}

impl<'a> ParserExt<'a> for Parser<'a> {
    fn parse_paths(&mut self) -> PResult<'a, Vec<Path>> {
        self.parse_seq_to_end(&Eof,
                              SeqSep::trailing_allowed(Comma),
                              |p| p.parse_path(PathStyle::Mod))
    }
}

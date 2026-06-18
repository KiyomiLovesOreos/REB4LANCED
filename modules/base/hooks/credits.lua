-- reb4l_credit(entries) → info_queue item that renders a Credits tooltip popout.
-- entries: list of { label, name, colour }
-- Example: reb4l_credit({ { 'Art', 'Solaskies', HEX('a0d8ef') } })
function reb4l_credit(entries)
    return {
        generate_ui = function(self, _iq, _card, desc_nodes)
            desc_nodes.name = 'Credits'
            for _, e in ipairs(self.entries) do
                desc_nodes[#desc_nodes + 1] = {
                    { n = G.UIT.T, config = { text = e[1] .. '  ', scale = 0.32, colour = G.C.UI.TEXT_INACTIVE } },
                    { n = G.UIT.T, config = { text = e[2],          scale = 0.32, colour = e[3] or G.C.WHITE    } },
                }
            end
        end,
        entries = entries,
    }
end

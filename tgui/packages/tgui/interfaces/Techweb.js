import { Button, Section, NoticeBox, Tabs, Box, Input, Flex, ProgressBar, Collapsible } from '../components';
import { Experiment } from './ExperimentConfigure';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';

export const Techweb = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    nodes,
    node_cache,
    design_cache,
    experiments,
    points,
    points_last_tick,
    web_org,
    sec_protocols,
  } = data;
  const [
    tabIndex,
    setTabIndex,
  ] = useLocalState(context, 'tabIndex', 1);
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText');

  let displayedNodes = nodes.filter(x => x.tier === tabIndex);
  displayedNodes.sort((a, b) => {
    const an = node_cache[a.id];
    const bn = node_cache[b.id];
    return an.name.localeCompare(bn.name);
  });

  if (searchText && searchText.trim() !== '') {
    displayedNodes = displayedNodes.filter(x => {
      const n = node_cache[x.id];
      return n.name.toLowerCase().includes(searchText)
        || n.description.toLowerCase().includes(searchText)
        || Object.keys(n.design_ids).some(e =>
          design_cache[e].name.toLowerCase().includes(searchText));
    });
  }

  return (
    <Window
      width={640}
      height={880}>
      <Window.Content>
        <Section title={`${web_org} Research and Development Network`}
          buttons={
            `GEN: ${points && points["General Research"] || 0} points (+${points_last_tick && points_last_tick["General Research"] || 0}/t)`
          }>
          <Flex justify={"space-between"}>
            <Flex.Item>
              <Tabs>
                <Tabs.Tab
                  selected={tabIndex === 0}
                  onClick={() => setTabIndex(0)}>
                  Researched
                </Tabs.Tab>
                <Tabs.Tab
                  selected={tabIndex === 1}
                  onClick={() => setTabIndex(1)}>
                  Available
                </Tabs.Tab>
                <Tabs.Tab
                  selected={tabIndex === 2}
                  onClick={() => setTabIndex(2)}>
                  Future
                </Tabs.Tab>
              </Tabs>
            </Flex.Item>
            <Flex.Item align={"center"}>
              <Input
                value={searchText}
                onInput={(e, value) => setSearchText(value)}
                placeholder={"Search..."} />
            </Flex.Item>
          </Flex>
          <Box scrollable>
            {displayedNodes.map((n, idx) => {
              return (
                <TechNode node={n} key={`n${idx}`} />
              );
            })}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};

const TechNode = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    node_cache,
    design_cache,
    experiments,
    points,
  } = data;
  const { node } = props;
  const {
    id,
    can_unlock,
    tier,
  } = node;
  let thisNode = node_cache[id];
  let reqExp = thisNode?.required_experiments;

  const expcompl = reqExp.filter(x => experiments[x]?.completed).length;
  const experimentProgress = (
    <ProgressBar
      ranges={{
        good: [0.5, Infinity],
        average: [0.25, 0.5],
        bad: [-Infinity, 0.25],
      }}
      value={expcompl / reqExp.length}>
      Experiments ({expcompl}/{reqExp.length})
    </ProgressBar>
  );

  return (
    <Section title={thisNode.name}
      buttons={tier === 1 && (
        <Button
          icon="lightbulb"
          disabled={!can_unlock}
          onClick={() => act("researchNode", { node_id: thisNode.id })}>
          Research
        </Button>
      )}>
      {tier !== 0 && (
        <Flex className="Techweb__NodeProgress">
          {Object.keys(thisNode.costs).map((k, i) => {
            const nodeProg = Math.min(thisNode.costs[k], points[k]) || 0;
            return (
              <Flex.Item grow={1} basis={0}
                key={`n${thisNode.id}p${i}`}>
                <ProgressBar
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.25, 0.5],
                    bad: [-Infinity, 0.25],
                  }}
                  value={Math.min(1, points[k] / thisNode.costs[k])}>
                  {k} ({nodeProg}/{thisNode.costs[k]})
                </ProgressBar>
              </Flex.Item>
            );
          })}
          {reqExp?.length > 0 && (
            <Flex.Item grow={1} basis={0}>
              {experimentProgress}
            </Flex.Item>
          )}
        </Flex>
      )}
      <div className="Techweb__NodeDescription">{thisNode.description}</div>
      <Box className="Techweb__NodeUnlockedDesigns">
        {Object.keys(thisNode.design_ids).map((k, i) => {
          return (
            <Button key={`${thisNode.id}${i}`}
              className={`design32x32 ${k} Techweb__DesignIcon`}
              tooltip={design_cache[k].name}
              tooltipPosition={i % 15 < 7 ? "right" : "left"} />
          );
        })}
      </Box>
      {thisNode.required_experiments?.length > 0
        && (
          <Collapsible
            className="Techweb__NodeExperimentsRequired"
            title="Required Experiments">
            {thisNode.required_experiments.map((k, i) => {
              const thisExp = experiments[k];
              if (thisExp === null || thisExp === undefined) {
                return (
                  <div>Failed to find experiment &apos;{k}&apos;</div>
                );
              }
              return (
                <Experiment key={`n${thisNode.id}e${i}`} exp={thisExp} />
              );
            })}
          </Collapsible>
        )}
    </Section>
  );
};
